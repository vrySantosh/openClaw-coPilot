# OpenClaw + GitHub Copilot Setup

Run AI agents on WhatsApp and Telegram using [OpenClaw](https://docs.openclaw.ai) powered by GitHub Copilot's free models (GPT-5 mini, GPT-4o).

## What This Does

- Connects OpenClaw to GitHub Copilot as the LLM backend (free with a GitHub account)
- Sets up a WhatsApp/Telegram chatbot powered by GPT-5 mini
- Optionally runs a VS Code remote executor for file/command operations via chat

## Prerequisites

- macOS (Linux support is experimental)
- [Node.js](https://nodejs.org/) v22+
- A GitHub account with [Copilot](https://github.com/features/copilot) access (free tier works)
- A phone number for WhatsApp, or a Telegram bot token

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

## Configuration

See [openclaw.example.json](openclaw.example.json) for a full annotated config template.

### Key Settings

| Setting | Description |
|---------|-------------|
| `agents.defaults.model.primary` | Default LLM model (`github-copilot/gpt-5-mini`) |
| `channels.whatsapp.allowFrom` | Phone numbers allowed to message the bot |
| `channels.whatsapp.dmPolicy` | `allowlist` (restricted) or `open` |
| `gateway.auth.token` | Gateway authentication token |
| `bindings` | Maps agents to channels (e.g. Vyra → WhatsApp) |

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
```

## License

MIT
