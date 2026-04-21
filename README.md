# chrisjohnson-plugins

Personal Claude Code plugin marketplace by Chris Johnson.

## Plugins

### claude-text-to-speech

Adds voice responses to Claude Code. Uses [ElevenLabs](https://elevenlabs.io) for high-quality voices if an API key is set, otherwise falls back to macOS `say`.

**Requirements:** macOS, `jq`, `curl` (for ElevenLabs)

**Usage:**
- Type `voice on` to enable voice responses
- Type `voice off` to disable (stops any in-progress playback)
- Type `voice stop` to interrupt current playback without disabling
- Voice is off by default

**Stop speech with a keyboard shortcut:**

You can set up a global macOS hotkey to stop speech instantly from any app:

1. Copy `extras/StopSpeech.workflow` to `~/Library/Services/`
2. Open **System Settings > Keyboard > Keyboard Shortcuts > Services > General**
3. Find **Stop Speech** and assign a shortcut (e.g., `⌘S` or `⌃.`)

The hotkey kills both ElevenLabs (`afplay`) and macOS `say` playback.

**ElevenLabs setup** (optional, for higher-quality voices):

1. Get an API key at https://elevenlabs.io/app/settings/api-keys
2. Save it to `~/.claude/secrets/elevenlabs.env` with `chmod 600`:
   ```bash
   mkdir -p ~/.claude/secrets
   echo 'ELEVENLABS_API_KEY="sk_your_key_here"' > ~/.claude/secrets/elevenlabs.env
   chmod 600 ~/.claude/secrets/elevenlabs.env
   ```
3. Optionally pick a voice — see https://elevenlabs.io/app/voice-library — and add `ELEVENLABS_VOICE_ID="..."` to the same file.

**Configuration** (env vars; put in `~/.claude/secrets/elevenlabs.env` or `~/.zshrc`):

| Variable | Default | Description |
|---|---|---|
| `ELEVENLABS_API_KEY` | (unset) | Enables ElevenLabs when set |
| `ELEVENLABS_VOICE_ID` | `JBFqnCBsd6RMkjVDRZzb` (George) | ElevenLabs voice ID |
| `ELEVENLABS_MODEL` | `eleven_multilingual_v2` | ElevenLabs model |
| `CLAUDE_TTS_VOICE` | `Lee (Premium)`, fallback `Samantha` | macOS voice (fallback only) |
| `CLAUDE_TTS_RATE` | `210` | macOS speech rate wpm (fallback only) |

**Fallback behavior:** If the ElevenLabs API call fails (bad key, rate limit, no network), the hook logs the error and falls back to `say` automatically.

**Tip:** For macOS fallback voices, download premium voices in System Settings > Accessibility > Spoken Content > System Voice > Manage Voices.

## Installation

Add the marketplace:

```
/plugin marketplace add Chrisj7264a/chrisjohnson-plugins
```

Install a plugin:

```
/plugin install claude-text-to-speech@chrisjohnson-plugins
```
