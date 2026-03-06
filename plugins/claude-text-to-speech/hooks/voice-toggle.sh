#!/bin/bash
# Voice toggle hook for Claude Code (UserPromptSubmit)
#
# Intercepts "voice on" / "voice off" prompts to toggle TTS.
# Blocks the prompt so it never reaches Claude.

TOGGLE_FILE="$HOME/.claude/tts-enabled"

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]' | xargs)

case "$PROMPT" in
  "voice on")
    touch "$TOGGLE_FILE"
    echo "Voice enabled." >&2
    exit 2  # block prompt from reaching Claude
    ;;
  "voice off")
    rm -f "$TOGGLE_FILE"
    # Kill any in-progress speech
    killall say 2>/dev/null
    echo "Voice disabled." >&2
    exit 2
    ;;
  *)
    exit 0  # pass through
    ;;
esac
