#!/bin/bash
# TTS hook for Claude Code — speaks the assistant's last response.
#
# Reads JSON from stdin (Stop hook), extracts last_assistant_message, and speaks it.
# Prefers ElevenLabs if ELEVENLABS_API_KEY is set (env or ~/.claude/secrets/elevenlabs.env).
# Falls back to macOS `say` otherwise.
#
# Toggle: type "voice on" / "voice off" in Claude Code to control.
# Interrupt: type "voice stop" to kill current playback without disabling.
#
# Configuration (env vars):
#   ELEVENLABS_API_KEY   - ElevenLabs API key (also read from ~/.claude/secrets/elevenlabs.env)
#   ELEVENLABS_VOICE_ID  - ElevenLabs voice ID (default: JBFqnCBsd6RMkjVDRZzb = George)
#   ELEVENLABS_MODEL     - ElevenLabs model (default: eleven_multilingual_v2)
#   CLAUDE_TTS_VOICE     - macOS voice name (fallback; default: Lee (Premium), then Samantha)
#   CLAUDE_TTS_RATE      - macOS speech rate wpm (fallback; default: 210)

TOGGLE_FILE="$HOME/.claude/tts-enabled"
SECRETS_FILE="$HOME/.claude/secrets/elevenlabs.env"

# Only speak if toggled on
[[ ! -f "$TOGGLE_FILE" ]] && exit 0

# Read JSON from stdin
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')
[[ -z "$MESSAGE" ]] && exit 0

# Strip markdown for cleaner speech
MESSAGE=$(echo "$MESSAGE" | sed -E '
  s/```[a-z]*//g;
  s/```//g;
  s/^#+\s*//g;
  s/\*\*([^*]+)\*\*/\1/g;
  s/\*([^*]+)\*/\1/g;
  s/`([^`]+)`/\1/g;
  s/^\s*[-*]\s*/. /g;
  s/\[([^]]+)\]\([^)]+\)/\1/g;
')

# Kill any in-progress playback before starting new one
pkill -x afplay 2>/dev/null
killall say 2>/dev/null

# Load ElevenLabs API key from env or secrets file
if [[ -z "$ELEVENLABS_API_KEY" && -f "$SECRETS_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$SECRETS_FILE"
fi

# Prefer ElevenLabs if key is set
if [[ -n "$ELEVENLABS_API_KEY" ]]; then
  VOICE_ID="${ELEVENLABS_VOICE_ID:-JBFqnCBsd6RMkjVDRZzb}"
  MODEL="${ELEVENLABS_MODEL:-eleven_multilingual_v2}"

  # Truncate to stay well under ElevenLabs per-request limits
  MESSAGE_TRUNCATED=$(echo "$MESSAGE" | head -c 4500)

  OUT_FILE="/tmp/claude-tts-$$-$(date +%s).mp3"

  # Build JSON body safely (jq handles escaping)
  BODY=$(jq -n --arg text "$MESSAGE_TRUNCATED" --arg model "$MODEL" \
    '{text: $text, model_id: $model}')

  # Call ElevenLabs in background so Claude Code is not blocked
  (
    HTTP_STATUS=$(curl -sS -w "%{http_code}" -o "$OUT_FILE" \
      -X POST "https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID" \
      -H "xi-api-key: $ELEVENLABS_API_KEY" \
      -H "Content-Type: application/json" \
      -H "Accept: audio/mpeg" \
      --max-time 60 \
      -d "$BODY")

    if [[ "$HTTP_STATUS" == "200" && -s "$OUT_FILE" ]]; then
      afplay "$OUT_FILE"
    else
      # Log to stderr and fall back to `say`
      echo "[tts.sh] ElevenLabs failed (HTTP $HTTP_STATUS) — falling back to macOS say" >&2
      if [[ -f "$OUT_FILE" ]]; then
        head -c 500 "$OUT_FILE" >&2
        echo "" >&2
      fi
      FALLBACK_VOICE="${CLAUDE_TTS_VOICE:-Lee (Premium)}"
      say -v "$FALLBACK_VOICE" -r "${CLAUDE_TTS_RATE:-210}" "$MESSAGE" 2>/dev/null \
        || say -v Samantha -r "${CLAUDE_TTS_RATE:-210}" "$MESSAGE"
    fi
    rm -f "$OUT_FILE"
  ) &
  exit 0
fi

# Fallback: macOS `say`
if [[ -z "$CLAUDE_TTS_VOICE" ]]; then
  if say -v 'Lee (Premium)' '' 2>/dev/null; then
    VOICE="Lee (Premium)"
  else
    VOICE="Samantha"
  fi
else
  VOICE="$CLAUDE_TTS_VOICE"
fi
RATE="${CLAUDE_TTS_RATE:-210}"

echo "$MESSAGE" | say -v "$VOICE" -r "$RATE" &
exit 0
