#!/bin/bash
# TTS hook for Claude Code - speaks the assistant's last response using macOS `say`
#
# Reads JSON from stdin (Stop hook), extracts last_assistant_message, and speaks it.
# Runs `say` in the background so it doesn't block Claude Code.
#
# Toggle: type "voice on" / "voice off" in Claude Code to control.
# Configuration (env vars):
#   CLAUDE_TTS_VOICE     - macOS voice name (default: Samantha)
#   CLAUDE_TTS_RATE      - Speech rate in words per minute (default: 210)
#   CLAUDE_TTS_MAX_CHARS - Max characters to speak (default: 500)

TOGGLE_FILE="$HOME/.claude/tts-enabled"

# Only speak if toggled on
[[ ! -f "$TOGGLE_FILE" ]] && exit 0

VOICE="${CLAUDE_TTS_VOICE:-Samantha}"
RATE="${CLAUDE_TTS_RATE:-210}"
MAX_CHARS="${CLAUDE_TTS_MAX_CHARS:-500}"

# Read JSON from stdin
INPUT=$(cat)

# Extract the last assistant message
MESSAGE=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')

# Nothing to say
[[ -z "$MESSAGE" ]] && exit 0

# Truncate if too long, adding ellipsis
if [[ ${#MESSAGE} -gt $MAX_CHARS ]]; then
  MESSAGE="${MESSAGE:0:$MAX_CHARS}... truncated."
fi

# Strip markdown formatting for cleaner speech
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

# Speak in background so we don't block Claude Code
say -v "$VOICE" -r "$RATE" "$MESSAGE" &

exit 0
