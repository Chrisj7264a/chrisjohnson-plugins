#!/bin/bash
# Voice toggle hook for Claude Code (UserPromptSubmit)
#
# Intercepts "voice on" / "voice off" / "voice stop" prompts.
# Blocks the prompt so it never reaches Claude.

TOGGLE_FILE="$HOME/.claude/tts-enabled"

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]' | xargs)

kill_playback() {
  pkill -x afplay 2>/dev/null
  killall say 2>/dev/null
  return 0
}

case "$PROMPT" in
  "voice on")
    touch "$TOGGLE_FILE"
    {
      echo "Voice enabled. Type these commands to control:"
      echo ""
      echo "  voice off    Disable voice"
      echo "  voice stop   Stop current playback (keeps voice enabled)"
      echo "  voice on     Enable voice (you are here)"
      echo ""
      if [[ -n "$ELEVENLABS_API_KEY" ]] || [[ -f "$HOME/.claude/secrets/elevenlabs.env" ]]; then
        echo "  Using ElevenLabs voice."
      else
        echo "  Using macOS voice (set ELEVENLABS_API_KEY to use ElevenLabs)."
      fi
    } >&2
    exit 2
    ;;
  "voice off")
    rm -f "$TOGGLE_FILE"
    kill_playback
    echo "Voice disabled." >&2
    exit 2
    ;;
  "voice stop")
    kill_playback
    echo "Playback stopped. Voice still enabled." >&2
    exit 2
    ;;
  *)
    exit 0
    ;;
esac
