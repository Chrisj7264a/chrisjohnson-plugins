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

### homebot-cycle-setup

Automates Linear project setup at the start of each Homebot Shape Up cycle. Pulls the cycle brief from Notion, finds pitches where you're listed as Driver, and creates one Linear project per pitch with milestones, summary (the pitch's `Done` outcome), description (pitch + brief links), team, initiatives, priority, dates, and an icon.

**Requirements:**
- Homebot Notion + Linear access (the skill is wired to Homebot's workspaces and the Pitches Database schema).
- Notion MCP and Linear MCP both connected and authenticated.

**One-time setup (recommended):**

Set your @homebot.ai email so the skill can find your pitches without prompting each run:

```bash
echo 'export HOMEBOT_USER_EMAIL="you@homebot.ai"' >> ~/.zshrc
source ~/.zshrc
```

If unset, the skill will prompt for it on first run.

**Usage:**

- "Set up Linear for cycle 4"
- "Kick off this cycle in Linear"
- `/cycle-linear-setup` (if Claude routes slash commands to the skill)

**What it does:**

1. Confirms scope: shows your committed pitches for the cycle and waits for `y / edit / cancel`.
2. For each pitch with no explicit milestone list, drafts 3-4 candidates and asks for approval; pitches with explicit milestones use the pitch verbatim.
3. Creates Linear projects in parallel (one per pitch) with team, initiatives, priority, dates, lead = you, status = Shaped, and an icon.
4. Creates milestones with the full scope from the pitch's "Boundaries → In" section, preserving bullet/numbered formatting.
5. Reports a summary table with Linear URLs and any assumptions/gaps to dial in.

After the run, dial in any gaps (Tech Lead, members, milestone tweaks) and flip Status from `Shaped` → `Bet` when ready.

## Installation

Add the marketplace:

```
/plugin marketplace add Chrisj7264a/chrisjohnson-plugins
```

Install a plugin:

```
/plugin install claude-text-to-speech@chrisjohnson-plugins
/plugin install homebot-cycle-setup@chrisjohnson-plugins
```
