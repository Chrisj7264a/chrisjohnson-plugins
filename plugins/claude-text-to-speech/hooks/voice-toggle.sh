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
    {
      echo "Voice enabled. Type these commands to control:"
      echo ""
      echo "  voice off    Disable voice"
      echo "  voice on     Enable voice (you are here)"
      echo ""
      if [[ -d "$HOME/Library/Services/StopSpeech.workflow" ]]; then
        echo "  Stop speech mid-playback with your 'Stop Speech' hotkey."
        echo "  (Set in System Settings > Keyboard > Keyboard Shortcuts > Services)"
      else
        echo "  To stop speech mid-playback, install the global hotkey:"
        echo "  Copy extras/StopSpeech.workflow to ~/Library/Services/"
        echo "  Then assign a shortcut in System Settings > Keyboard > Keyboard Shortcuts > Services"
      fi
    } >&2
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
