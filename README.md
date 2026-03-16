<p align="center">
  <img src="assets/IMG_2680.png" alt="OpenClaw Mascot" style="max-width: 400px;" />
</p>

[![Brave Frog](https://img.shields.io/badge/Brave-Frog-4caf50.svg)](https://example.com) [![Vyra Frog](https://img.shields.io/badge/Vyra-Frog-4caf50.svg)](https://example.com) [![Made with ❤️](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red.svg)](https://example.com)

# OpenClaw + GitHub Copilot Setup



Run AI agents on WhatsApp, Telegram, and Slack using [OpenClaw](https://docs.openclaw.ai) powered by GitHub Copilot's free models (GPT-5 mini, GPT-4o).

## What This Does

- Connects OpenClaw to GitHub Copilot as the LLM backend (free with a GitHub account)
- Sets up a WhatsApp/Telegram/Slack chatbot powered by GPT-5 mini
- Local voice transcription via [whisper.cpp](https://github.com/ggerganov/whisper.cpp) (OpenAI Whisper model, runs fully offline)
- Text-to-speech synthesis via Coqui TTS (optional)
- Optionally runs a VS Code remote executor for file/command operations via chat

## Prerequisites

- macOS (Linux support is experimental)
- [Node.js](https://nodejs.org/) v22+
- A GitHub account with [Copilot](https://github.com/features/copilot) access (free tier works)
- A phone number for WhatsApp, or a Telegram bot token, or a Slack workspace

## Quick Start

### 1. Install OpenClaw

```bash
npm install -g openclaw
```

### 2. Run the Setup Wizard

```bash
openclaw configure
```

This walks you through:
- Linking your GitHub Copilot credentials
- Choosing a default model
- Connecting a chat channel (WhatsApp or Telegram)

### 3. Copy the Example Config

```bash
cp openclaw.example.json ~/.openclaw/openclaw.json
```

Edit `~/.openclaw/openclaw.json` and replace the placeholder values:
- `+YOUR_PHONE_NUMBER` → your WhatsApp number (e.g. `+14155550123`)
- `REPLACE_WITH_YOUR_GATEWAY_TOKEN` → run `openssl rand -hex 24` to generate one

### 4. Authenticate GitHub Copilot

```bash
openclaw models auth --provider github-copilot
```

### 5. Connect WhatsApp

```bash
openclaw channels login --channel whatsapp
```

Scan the QR code with your phone to link WhatsApp Web.

### 6. Start the Gateway

```bash
openclaw gateway
```

Send a message to yourself on WhatsApp — the agent will reply.

## Slack Integration

OpenClaw supports Slack as a chat channel using Socket Mode (no public URL required).

### 1. Create a Slack App

1. Go to [api.slack.com/apps](https://api.slack.com/apps) → **Create New App** → **From scratch**
2. Under **Socket Mode**, enable it and generate an **App-Level Token** (`xapp-...`) with `connections:write` scope
3. Under **OAuth & Permissions**, add these Bot Token Scopes:
   - `chat:write`
   - `app_mentions:read`
   - `im:history`
   - `im:read`
   - `im:write`
4. Under **Event Subscriptions**, enable events and subscribe to:
   - `message.im`
   - `app_mention`
5. Install the app to your workspace and copy the **Bot User OAuth Token** (`xoxb-...`)

### 2. Connect Slack to OpenClaw

```bash
openclaw channels add --channel slack --bot-token xoxb-YOUR-BOT-TOKEN --app-token xapp-YOUR-APP-TOKEN
```

Or add the Slack section manually to your `openclaw.json` (see [openclaw.example.json](openclaw.example.json) for the full template).

### 3. Bind an Agent to Slack

Add a Slack binding in `openclaw.json`:

```json
{
  "agentId": "vyra",
  "match": {
    "channel": "slack",
    "accountId": "default"
  }
}
```

Restart the gateway — your agent will now respond to DMs and @mentions in Slack.

## Local Voice Transcription (OpenAI Whisper)

The `voice-local/` directory contains a fully local, offline voice transcription pipeline using [whisper.cpp](https://github.com/ggerganov/whisper.cpp) — a C/C++ port of OpenAI's Whisper model. No API keys, no cloud calls, completely free.

### 1. Install whisper.cpp and Download a Model

```bash
chmod +x ~/.openclaw/voice-local/install.sh
~/.openclaw/voice-local/install.sh
```

Then download the Whisper model:

```bash
mkdir -p ~/.whisper && cd ~/.whisper
curl -L -o tiny.en.ggmlv3.q4_0.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/models/ggml-tiny.en.bin
```

> **Tip:** `tiny.en` is fast and lightweight (~75 MB). For better accuracy, use `base.en` or `small.en`.

### 2. Transcribe an Audio File

```bash
~/.openclaw/voice-local/transcribe.sh /path/to/audio.wav
```

Outputs a `.txt` file alongside the audio with the transcript.

### 3. Run the Voice Server (Optional)

A minimal Express server that accepts audio uploads and returns transcriptions:

```bash
cd ~/.openclaw/voice-local && npm install express multer
node ~/.openclaw/voice-local/server.js
```

POST audio (multipart `audio` field) to `http://localhost:3003/transcribe`:

```bash
curl -F "audio=@recording.wav" http://localhost:3003/transcribe
# → {"transcript": "Hello, this is a test."}
```

> **Security note:** The voice server is local-only by default. Do not expose it publicly without adding TLS and authentication.

### 4. Text-to-Speech (Optional)

Coqui TTS can synthesize speech locally:

```bash
python3 -m venv ~/.uix-voice-venv
source ~/.uix-voice-venv/bin/activate
pip install TTS soundfile
~/.openclaw/voice-local/synthesize.sh "Hello from OpenClaw" output.wav
```

## Configuration

See [openclaw.example.json](openclaw.example.json) for a full annotated config template.

### Key Settings

| Setting | Description |
|---------|-------------|
| `agents.defaults.model.primary` | Default LLM model (`github-copilot/gpt-5-mini`) |
| `channels.whatsapp.allowFrom` | Phone numbers allowed to message the bot |
| `channels.whatsapp.dmPolicy` | `allowlist` (restricted) or `open` |
| `channels.slack.botToken` | Slack Bot User OAuth Token (`xoxb-...`) |
| `channels.slack.appToken` | Slack App-Level Token (`xapp-...`) |
| `gateway.auth.token` | Gateway authentication token |
| `bindings` | Maps agents to channels (e.g. Vyra → WhatsApp, Slack) |

### Available Free Models

| Model | Provider | Notes |
|-------|----------|-------|
| `github-copilot/gpt-5-mini` | GitHub Copilot | Fast, free, good default |
| `github-copilot/gpt-4o` | GitHub Copilot | More capable, uses premium quota |
| `openrouter/google/gemma-3-27b-it:free` | OpenRouter | Free, no API key needed |

### Multiple Agents

You can define separate agents with different personalities. The example config includes:

- **main** — default agent
- **Vyra** — a named agent bound to WhatsApp with its own identity

```json
{
  "id": "vyra",
  "name": "Vyra",
  "model": "github-copilot/gpt-5-mini",
  "identity": {
    "name": "Vyra",
    "emoji": "✨"
  }
}
```

## Optional: VS Code Remote Executor

The included `vscode-executor.js` lets the agent execute commands on your Mac:

```bash
# Test it directly
node vscode-executor.js "create file hello.js"
node vscode-executor.js "list files"
node vscode-executor.js "run git status"
```

The `integration.sh` script bridges chat messages to the executor:

```bash
./integration.sh setup    # First-time setup
./integration.sh execute "create file app.jsx"
./integration.sh status
```

## Troubleshooting

### 400 `invalid_request_body` errors
Clear stale sessions: remove `.jsonl` files in `~/.openclaw/agents/<agent>/sessions/` and restart the gateway.

### WhatsApp won't connect
```bash
openclaw channels login --channel whatsapp --verbose
```
Re-scan the QR code. If credentials are stale, delete `~/.openclaw/credentials/whatsapp/` and retry.

### Model auth failures
```bash
openclaw models auth --provider github-copilot
openclaw models status
```

### Version mismatch warnings
```bash
openclaw update
# or manually:
npm install -g openclaw@latest
```

## Project Structure

```
openclaw.example.json   # Template config — copy to ~/.openclaw/openclaw.json
vscode-executor.js      # VS Code remote command executor (optional)
integration.sh          # Chat-to-executor bridge script (optional)
slack-app-manifest.yaml # Slack app setup command reference
voice-local/            # Local voice transcription & TTS scaffold
  install.sh            # Builds whisper.cpp and downloads models
  transcribe.sh         # Transcribe audio files using Whisper
  synthesize.sh         # Text-to-speech via Coqui TTS
  server.js             # HTTP server for audio upload → transcription
```

## License

MIT
