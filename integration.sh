#!/bin/bash
# OpenClaw ↔ VS Code Integration Script
# Bridges chat commands to VS Code executor

set -e

EXECUTOR_PATH="/Users/santosh/.openclaw/vscode-executor.js"
SKILL_NAME="vscode-remote-executor"
WORKSPACE_DIR="/Users/santosh/.openclaw/vscode-workspace"
LOG_FILE="/Users/santosh/.openclaw/integration.log"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

# Function: Execute instruction via executor
execute_instruction() {
    local instruction="$1"
    log "Executing instruction: $instruction"
    
    result=$(node "$EXECUTOR_PATH" "$instruction" 2>&1)
    echo "$result"
}

# Function: Send result back via WhatsApp/Telegram
send_via_channel() {
    local channel="$1"
    local target="$2"
    local message="$3"
    
    log "Sending result via $channel to $target"
    
    openclaw message send \
        --channel "$channel" \
        --target "$target" \
        --message "$message" \
        --json 2>&1 || error "Failed to send message"
}

# Function: Handle incoming message
handle_message() {
    local channel="$1"
    local sender="$2"
    local message="$3"
    
    log "Received from $sender via $channel: $message"
    
    # Execute the instruction
    result=$(execute_instruction "$message")
    
    # Extract success status and response
    success_status=$(echo "$result" | grep -o '"success":[^,}]*' | grep -o 'true\|false')
    
    # Format response
    if [[ "$success_status" == "true" ]]; then
        response="✅ Command executed successfully:\n$result"
        success "Command executed"
    else
        response="❌ Command failed:\n$result"
        error "Command failed"
    fi
    
    # Send back via same channel
    send_via_channel "$channel" "$sender" "$response"
}

# Function: Listen for messages (polling)
listen_for_messages() {
    local channel="$1"
    
    log "Listening for messages on $channel..."
    
    # This would require implementing a message polling mechanism
    # For now, show instructions
    echo "Message listener not yet implemented"
    echo "Use: openclaw agent --agent main --message 'your instruction'"
}

# Function: Setup integration
setup_integration() {
    log "Setting up VS Code ↔ OpenClaw integration..."
    
    # Ensure workspace exists
    mkdir -p "$WORKSPACE_DIR"
    success "Workspace created: $WORKSPACE_DIR"
    
    # Verify executor exists
    if [[ -f "$EXECUTOR_PATH" ]]; then
        success "Executor found"
    else
        error "Executor not found at $EXECUTOR_PATH"
        exit 1
    fi
    
    # Test executor
    log "Testing executor..."
    test_result=$(node "$EXECUTOR_PATH" "status" 2>&1)
    if echo "$test_result" | grep -q 'success.*true'; then
        success "Executor is operational"
    else
        error "Executor test failed"
        log "Output: $test_result"
        exit 1
    fi
    
    # Create integration script in bin
    mkdir -p /usr/local/bin
    ln -sf "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")" /usr/local/bin/openclaw-vscode 2>/dev/null || true
    
    log "Integration setup complete!"
    echo ""
    echo "=== Integration Ready ==="
    echo "Usage:"
    echo "  openclaw-vscode 'create file myfile.js'"
    echo "  openclaw-vscode 'list files'"
    echo "  openclaw-vscode 'run npm install'"
    echo ""
    echo "Or via OpenClaw:"
    echo "  openclaw agent --agent main --message 'create file test.js'"
}

# Function: Show status
show_status() {
    log "=== Integration Status ==="
    echo "Executor: $(test -f "$EXECUTOR_PATH" && echo 'OK' || echo 'MISSING')"
    echo "Workspace: $(test -d "$WORKSPACE_DIR" && echo 'OK' || echo 'MISSING')"
    echo "Files in workspace: $(ls -1 "$WORKSPACE_DIR" 2>/dev/null | wc -l)"
    echo "Gateway: $(openclaw health 2>/dev/null | grep -q 'Agents:' && echo 'RUNNING' || echo 'STOPPED')"
    echo "Channels: $(openclaw channels list 2>/dev/null | grep -c 'Channel' || echo '0')"
    echo ""
    echo "Log file: $LOG_FILE"
}

# Main command handler
case "${1:-}" in
    execute|run)
        execute_instruction "${2:-status}"
        ;;
    listen)
        listen_for_messages "${2:-telegram}"
        ;;
    setup)
        setup_integration
        ;;
    status)
        show_status
        ;;
    send)
        send_via_channel "$2" "$3" "$4"
        ;;
    *)
        echo "Usage: $0 [command] [args...]"
        echo ""
        echo "Commands:"
        echo "  execute, run <instruction>     Execute VS Code instruction"
        echo "  listen <channel>              Listen for messages"
        echo "  setup                         Initialize integration"
        echo "  status                        Show integration status"
        echo "  send <channel> <target> <msg> Send message"
        echo ""
        echo "Example:"
        echo "  $0 execute 'create file test.js'"
        echo "  $0 status"
        echo "  $0 setup"
        ;;
esac
