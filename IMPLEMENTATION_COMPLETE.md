# 🦞 OpenClaw Remote VS Code Executor - Complete Setup

**Goal**: Send commands to your Mac via WhatsApp/Telegram and execute them in VS Code remotely through OpenClaw

**Status**: ✅ All components ready

---

## 📋 What's Installed

| Component | Status | Location |
|-----------|--------|----------|
| OpenClaw Gateway | ✅ Running | `ws://127.0.0.1:19001` |
| VS Code Executor | ✅ Operational | `~/.openclaw/vscode-executor.js` |
| Integration Script | ✅ Ready | `~/.openclaw/integration.sh` |
| Default Model | ✅ Google Gemma Free | `openrouter/google/gemma-3-27b-it:free` |

---

## 🚀 Quick Start (Complete Workflow)

### 1️⃣ Start the Gateway (Terminal 1)

```bash
openclaw gateway
```

Output should show:
```
🦞 OpenClaw 2026.3.13
Connected, Idle...
```

### 2️⃣ Set Up Your Chat Channel (Terminal 2)

#### Option A: Telegram (Recommended - Simplest)

1. Go to Telegram → Search **@BotFather**
2. Send `/start` → `/newbot` → Give it a name
3. Copy the token (format: `5244655:AABfH7...`)

Add to OpenClaw:
```bash
openclaw channels add \
  --channel telegram \
  --token "YOUR_BOT_TOKEN" \
  --name "VS Code Remote"
```

#### Option B: WhatsApp (Your Target)

```bash
# This generates a QR code to scan with WhatsApp
openclaw channels add --channel whatsapp
```

Then scan the QR code with your phone camera → "Open in WhatsApp"

### 3️⃣ Send Your First Command

**Via Telegram:**
```bash
openclaw message send \
  --channel telegram \
  --target @YourTelegramUsername \
  --message "create file hello.js"
```

**Or via WhatsApp (after setup):**
```bash
openclaw message send \
  --channel whatsapp \
  --target "+1234567890" \
  --message "create file hello.js"
```

---

## 💻 Example Commands

Send these via WhatsApp/Telegram to execute on your Mac:

| Command | Result |
|---------|--------|
| `create file app.jsx` | Creates new React component |
| `list files` | Shows all files in workspace |
| `run npm install` | Installs npm packages |
| `run git status` | Shows git status |
| `open app.jsx in vscode` | Opens file in VS Code |
| `status` | Shows executor health |

### Real-World Workflow

```
You (in WhatsApp):
"Create a React component called Home.jsx with useState import"

↓ (OpenClaw processes the request)

VS Code Executor:
Creates: /Users/santosh/.openclaw/vscode-workspace/Home.jsx

↓ (Sends result back)

WhatsApp Reply:
✅ Created: Home.jsx at /Users/santosh/.openclaw/vscode-workspace/Home.jsx
```

---

## 🔧 Manual Testing

### 1. Test Executor Directly

```bash
# Create file
node ~/.openclaw/vscode-executor.js "create file test.js"

# List files
node ~/.openclaw/vscode-executor.js "list files"

# Run command
node ~/.openclaw/vscode-executor.js "run pwd"

# Check status
node ~/.openclaw/vscode-executor.js "status"
```

### 2. Test via Integration Script

```bash
# Execute an instruction
~/.openclaw/integration.sh execute "create file test.txt"

# Show status
~/.openclaw/integration.sh status

# Check integration logs
tail -50 ~/.openclaw/integration.log
```

### 3. Test via OpenClaw Agent

```bash
# Send to OpenClaw agent directly (uses local executor)
openclaw agent --agent main --message "create file agent-test.js"

# Send to agent and deliver reply via WhatsApp
openclaw agent \
  --agent main \
  --channel whatsapp \
  --target "+1234567890" \
  --message "list files" \
  --deliver
```

---

## 📁 Workspace Files

All executed files are stored here:
```bash
~/.openclaw/vscode-workspace/
```

View them:
```bash
ls -la ~/.openclaw/vscode-workspace/
```

---

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    You                                   │
│              (WhatsApp/Telegram)                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
        ┌────────────────────────┐
        │   Internet / Network   │
        └────────────┬───────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│              OpenClaw Gateway (Mac)                      │
│         ws://127.0.0.1:19001                            │
└────────────┬──────────────────────┬────────────────────┘
             │                      │
             ↓                      ↓
      ┌─────────────┐      ┌──────────────────┐
      │ Telegram    │      │ WhatsApp         │
      │ Channel     │      │ Channel          │
      └──────┬──────┘      └────────┬─────────┘
             │                      │
             └───────────┬──────────┘
                         ↓
        ┌────────────────────────────┐
        │ VS Code Executor           │
        │ vscode-executor.js         │
        └────────────┬───────────────┘
                     ↓
        ┌────────────────────────────┐
        │ Your Mac / VS Code         │
        │ (File creation, commands)  │
        └────────────────────────────┘
```

---

## 🔐 Security & Privacy

### API Keys
- Store in environment variables (never in code):
  ```bash
  export OPENCLAW_TELEGRAM_TOKEN="your_token"
  export OPENROUTER_API_KEY="your_key"
  ```

### Authorization
- Only accept commands from your own WhatsApp number
- Verify sender before executing:
  ```bash
  if [ "$SENDER" == "+1234567890" ]; then
    execute_command
  fi
  ```

### Firewall
- Gateway only listens on localhost: `127.0.0.1:19001`
- Can only be accessed from your Mac (unless exposed via Tailscale/VPN)

---

## 🚨 Troubleshooting

### Gateway won't start
```bash
# Check if port is in use
lsof -i :19001

# Kill existing process
lsof -i :19001 | awk 'NR!=1 {print $2}' | xargs kill -9

# Start with different port
openclaw gateway --port 18789
```

### Channel not working
```bash
# Check channel status
openclaw channels status --probe

# List configured channels
openclaw channels list

# Check gateway logs
openclaw logs --follow
```

### Executor errors
```bash
# Test executor directly
node ~/.openclaw/vscode-executor.js "status"

# Check executor logs
cat ~/.openclaw/executor-log.txt

# View integration logs
tail -100 ~/.openclaw/integration.log
```

### WhatsApp not connecting
```bash
# Generate new QR code
openclaw channels add --channel whatsapp

# Verify via directory lookup
openclaw directory self
opencv channels resolve
```

---

## ⚙️ Advanced Configuration

### Change Default Model
```bash
openclaw models set "openrouter/meta-llama/llama-3.3-70b"
```

### Add Multiple Channels
```bash
# Discord
openclaw channels add --channel discord --token YOUR_DISCORD_TOKEN

# Slack
openclaw channels add --channel slack --token YOUR_SLACK_TOKEN
```

### Custom Executor Command
```bash
# Create custom command
alias vscode-exec='node ~/.openclaw/vscode-executor.js'

# Use it
vscode-exec "create file custom.js"
```

### View All Logs
```bash
# OpenClaw gateway logs
openclaw logs --follow

# Integration script logs
tail -f ~/.openclaw/integration.log

# Executor logs
tail -f ~/.openclaw/executor-log.txt
```

---

## ✅ Implementation Checklist

Project setup complete! Here's your next steps:

- [x] OpenClaw installed & configured
- [x] Gateway running  
- [x] VS Code executor created & tested
- [x] Integration script ready
- [ ] **Telegram OR WhatsApp channel added**
  - Go to step 2️⃣ above
- [ ] **Send first test command**
  - Go to step 3️⃣ above
- [ ] Verify file created in `~/.openclaw/vscode-workspace/`
- [ ] Open file in VS Code

---

## 📞 Next Commands to Run

```bash
# 1. Check everything is ready
~/.openclaw/integration.sh status

# 2. Set up your channel (pick one)
# Telegram: 
#   openclaw channels add --channel telegram --token YOUR_TOKEN
# WhatsApp:
#   openclaw channels add --channel whatsapp

# 3. Verify channel is connected
openclaw channels list

# 4. Send your first command
openclaw message send --channel telegram --target @yourname --message "status"

# 5. Monitor results
openclaw logs --follow
```

---

## 📚 Reference

- **Gateway Status**: http://127.0.0.1:19001 (local only)
- **Dashboard**: `openclaw dashboard`
- **CLI Docs**: `openclaw --help`
- **Full Guide**: `/Users/santosh/.openclaw/SETUP_GUIDE.md`
- **Configuration**: `/Users/santosh/.openclaw/openclaw.json`

---

**Your setup is COMPLETE!** 🎉  
Now proceed to setting up WhatsApp/Telegram above. Good luck! 🚀
