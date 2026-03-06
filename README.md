# chrisjohnson-plugins

Personal Claude Code plugin marketplace by Chris Johnson.

## Plugins

### claude-text-to-speech

Adds voice responses to Claude Code using macOS text-to-speech. Claude speaks its responses aloud when enabled.

**Requirements:** macOS (uses the built-in `say` command), `jq`

**Usage:**
- Type `voice on` to enable voice responses
- Type `voice off` to disable (also stops any in-progress speech)
- Voice is off by default

**Stop speech with a keyboard shortcut:**

You can set up a global macOS hotkey to stop speech instantly from any app:

1. Copy `extras/StopSpeech.workflow` to `~/Library/Services/`
2. Open **System Settings > Keyboard > Keyboard Shortcuts > Services > General**
3. Find **Stop Speech** and assign a shortcut (e.g., `⌘S` or `⌃.`)

**Configuration** (optional environment variables in `~/.zshrc`):

| Variable | Default | Description |
|---|---|---|
| `CLAUDE_TTS_VOICE` | `Samantha` | macOS voice name (run `say -v '?'` to list available voices) |
| `CLAUDE_TTS_RATE` | `210` | Speech rate in words per minute |

**Tip:** Download premium voices in System Settings > Accessibility > Spoken Content > System Voice > Manage Voices for better quality.

## Installation

Add the marketplace:

```
/plugin marketplace add Chrisj7264a/chrisjohnson-plugins
```

Install a plugin:

```
/plugin install claude-text-to-speech@chrisjohnson-plugins
```
