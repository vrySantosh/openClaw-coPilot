# OpenClaw Remote Executor Setup Guide
**Goal**: Control VS Code on Mac remotely via WhatsApp/Telegram through OpenClaw

---

## 🚀 Quick Start: 3-Step Setup

### Step 1: Telegram Setup (Fastest for Testing)

Get your Telegram Bot Token:
1. Open Telegram and search for **@BotFather**
2. Send `/start` → `/newbot` → name it (e.g., "My VS Code Bot")
3. Copy the token (format: `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)

Add bot to OpenClaw:
```bash
openclaw channels add \
  --channel telegram \
  --token "YOUR_BOT_TOKEN_HERE" \
  --name "My AI Bot"
```

### Step 2: WhatsApp Setup (Your Target)

WhatsApp Web method:
```bash
# First try (may need WhatsApp Web available):
openclaw channels add --channel whatsapp

# This will generate a QR code for WhatsApp Web authentication
# Scan with your phone camera → Open in WhatsApp
```

**Alternative if above fails:**
- Manually link WhatsApp auth via `/pair` command after gateway starts
- Or use WhatsApp Business API (requires account setup)

### Step 3: VS Code Remote Executor

Create VS Code executor script:
```bash
# Start VS Code with accept-server-security-policy flag
open -a "Visual Studio Code" \
  --args --accept-server-security-policy \
  /path/to/your/workspace
```

---

## 🤖 Create VS Code Executor Skill

Create file: `~/.openclaw/workspace/skills/vscode-executor.md`

```markdown
# VS Code Executor Skill

Allows OpenClaw to execute commands in VS Code on Mac and return results.

## Usage

Execute shell commands and VS Code operations via:
- code --help
- Terminal commands
- File operations

## Execution Flow

1. Receive instruction from WhatsApp
2. Parse command
3. Execute in VS Code / Terminal
4. Return output back to WhatsApp
```

---

## 🔗 End-to-End Workflow

### Flow Diagram

```
You (WhatsApp)
    ↓
[@yourname: "create a React file"]
    ↓
OpenClaw Gateway
    ↓
VS Code Executor Skill
    ↓
Execute: touch App.jsx
    ↓
✓ Success: "Created App.jsx"
    ↓
WhatsApp Reply
    ↓
You see result instantly
```

---

## 📝 Example Commands to Try

After setup complete:

**Via Telegram/WhatsApp:**

```
"Create a new file called test.js with console.log('hello')"
→ OpenClaw executes → File created

"Show me files in ~/Desktop"
→ OpenClaw runs ls → Lists files in WhatsApp

"What's the current time in my VS Code terminal?"
→ OpenClaw runs date command → You get response
```

---

## ⚙️ Detailed Configuration

### Gateway Status Check
```bash
openclaw health
openclaw status
```

### Channel Status
```bash
openclaw channels list
openclaw channels status
```

### Message History
```bash
openclaw sessions
openclaw logs
```

---

## 🎯 Next: Test the Connection

1. **Start gateway** (if not running):
   ```bash
   openclaw gateway
   ```

2. **Send test message via Telegram**:
   ```bash
   openclaw message send \
     --channel telegram \
     --target @YourBotUsername \
     --message "Hello from OpenClaw!"
   ```

3. **Verify WhatsApp link**:
   ```bash
   openclaw channels status --deep
   ```

---

## 🔐 Security Notes

- Keep API tokens private (never commit to git)
- Use environment variables:
  ```bash
  export OPENCLAW_TELEGRAM_TOKEN="your_token"
  ```

- Restrict who can send commands (optional):
  ```bash
  openclaw message send \
    --channel telegram \
    --target @YourUsername \
    --message "test" \
    --require-auth
  ```

---

## 📚 Useful Commands Reference

```bash
# Show all available models
openclaw models list

# Change default model
openclaw models set "openrouter/google/gemma-3-27b-it:free"

# View config
openclaw config file

# List skills
openclaw skills

# Open dashboard
openclaw dashboard

# Interactive TUI
openclaw tui
```

---

## ✅ Implementation Checklist

- [ ] Gateway running: `openclaw gateway`
- [ ] Telegram bot token obtained (from @BotFather)
- [ ] Telegram channel configured
- [ ] Telegram test message sent successfully
- [ ] VS Code executor skill created
- [ ] WhatsApp connected (when ready)
- [ ] Sent first VS Code command via WhatsApp
- [ ] Confirmed file created/modified

---

## 🆘 Troubleshooting

### Gateway won't start
```bash
# Check if port 19001 is in use
lsof -i :19001

# Use different port
openclaw gateway --port 18789
```

### Channel auth failing
```bash
# Clear auth and retry
openclaw models auth clear
openclaw channels add --channel telegram --token YOUR_TOKEN
```

### Message not sending
```bash
# Check channel status
openclaw channels status --probe

# View logs
openclaw logs --follow
```

---

**Status**: ✅ Gateway running on `ws://127.0.0.1:19001`  
**Model**: Google Gemma 27B Free  
**Next Step**: Configure Telegram/WhatsApp + create executor
