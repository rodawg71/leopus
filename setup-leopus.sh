#!/usr/bin/env bash
set -euo pipefail
umask 077

# ============================================================
# LeOpus Edition — One-Command OpenClaw Setup
# Only input: Telegram bot token
# LLM: Ollama + Qwen3 8B (free, local, zero cost)
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_DIR="$HOME/.openclaw"
WORKSPACE_DIR="$OPENCLAW_DIR/workspace"
TEMPLATES="$SCRIPT_DIR/templates/leopus"

info()    { echo -e "  ${BLUE}ℹ${NC}  $1"; }
success() { echo -e "  ${GREEN}✅${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠️${NC}  $1"; }
die()     { echo -e "  ${RED}❌${NC} $1"; exit 1; }
ask()     { echo -en "  ${CYAN}?${NC}  $1: "; }

random_hex() {
  openssl rand -hex 32 2>/dev/null \
    || python3 -c "import secrets; print(secrets.token_hex(32))" 2>/dev/null \
    || head -c 64 /dev/urandom | xxd -p -c 64
}

banner() {
  clear
  echo ""
  echo -e "${CYAN}  ██╗     ███████╗ ██████╗ ██████╗ ██╗   ██╗███████╗${NC}"
  echo -e "${CYAN}  ██║     ██╔════╝██╔═══██╗██╔══██╗██║   ██║██╔════╝${NC}"
  echo -e "${CYAN}  ██║     █████╗  ██║   ██║██████╔╝██║   ██║███████╗${NC}"
  echo -e "${CYAN}  ██║     ██╔══╝  ██║   ██║██╔═══╝ ██║   ██║╚════██║${NC}"
  echo -e "${CYAN}  ███████╗███████╗╚██████╔╝██║     ╚██████╔╝███████║${NC}"
  echo -e "${CYAN}  ╚══════╝╚══════╝ ╚═════╝ ╚═╝      ╚═════╝ ╚══════╝${NC}"
  echo ""
  echo -e "  ${BOLD}Battle-tested AI assistant. One token. Zero cost.${NC}"
  echo -e "  Powered by OpenClaw + Ollama (local LLM)"
  echo ""
}

# ============================================================
# Hardware check
# ============================================================
check_hardware() {
  info "Checking hardware..."

  # RAM
  local ram_gb
  if [[ "$(uname)" == "Darwin" ]]; then
    ram_gb=$(( $(sysctl -n hw.memsize) / 1073741824 ))
  else
    ram_gb=$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1048576 ))
  fi

  if [ "$ram_gb" -lt 16 ]; then
    die "Need at least 16GB RAM (found ${ram_gb}GB). Qwen3 8B needs ~6GB for the model + headroom."
  elif [ "$ram_gb" -lt 32 ]; then
    warn "Found ${ram_gb}GB RAM. Will work, but 32GB+ recommended for best performance."
  else
    success "RAM: ${ram_gb}GB"
  fi

  # GPU detection
  if [[ "$(uname)" == "Darwin" ]]; then
    if sysctl -n machdep.cpu.brand_string 2>/dev/null | grep -qi "apple"; then
      success "GPU: Apple Silicon (Metal acceleration)"
    else
      warn "No Apple Silicon detected. Ollama will use CPU (slower)."
    fi
  elif command -v nvidia-smi &>/dev/null; then
    local gpu_name
    gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    success "GPU: $gpu_name (CUDA acceleration)"
  else
    warn "No NVIDIA GPU detected. Ollama will use CPU (slower but functional)."
  fi
}

# ============================================================
# Install system dependencies
# ============================================================
install_deps() {
  info "Checking system dependencies..."

  # Node.js 22+
  if ! command -v node &>/dev/null || [ "$(node -v | sed 's/v//' | cut -d. -f1)" -lt 22 ]; then
    info "Installing Node.js 22..."
    if [[ "$(uname)" == "Darwin" ]]; then
      if command -v brew &>/dev/null; then
        brew install node@22
      else
        die "Install Homebrew first: https://brew.sh"
      fi
    elif command -v apt-get &>/dev/null; then
      sudo apt-get update -qq
      sudo apt-get install -y -qq curl git build-essential
      curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/ns.sh
      sudo bash /tmp/ns.sh
      sudo apt-get install -y -qq nodejs
      rm -f /tmp/ns.sh
    else
      die "Cannot auto-install Node.js. Install Node.js 22+ manually."
    fi
    success "Node.js $(node -v) installed"
  else
    success "Node.js $(node -v)"
  fi

  # Git
  if ! command -v git &>/dev/null; then
    if [[ "$(uname)" == "Darwin" ]]; then
      xcode-select --install 2>/dev/null || true
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install -y -qq git
    fi
  fi
  success "git $(git --version | awk '{print $3}')"
}

# ============================================================
# Install Ollama + pull model
# ============================================================
install_ollama() {
  if ! command -v ollama &>/dev/null; then
    info "Installing Ollama (local LLM runtime)..."
    curl -fsSL https://ollama.com/install.sh | sh
    success "Ollama installed"
  else
    success "Ollama already installed"
  fi

  # Ensure ollama is running
  if ! curl -sf http://localhost:11434/api/tags &>/dev/null; then
    info "Starting Ollama..."
    if [[ "$(uname)" == "Darwin" ]]; then
      open -a Ollama 2>/dev/null || ollama serve &>/dev/null &
    else
      ollama serve &>/dev/null &
    fi
    sleep 3
    if ! curl -sf http://localhost:11434/api/tags &>/dev/null; then
      die "Ollama failed to start. Try running 'ollama serve' manually."
    fi
  fi
  success "Ollama running"

  # Pull model
  if ollama list 2>/dev/null | grep -q "qwen3:8b"; then
    success "Qwen3 8B already downloaded"
  else
    echo ""
    info "Downloading Qwen3 8B (~5GB one-time download)..."
    info "This is your AI brain. It runs 100% locally — no API key, no cost, ever."
    echo ""
    ollama pull qwen3:8b
    success "Qwen3 8B ready"
  fi
}

# ============================================================
# Install OpenClaw
# ============================================================
install_openclaw() {
  if command -v openclaw &>/dev/null; then
    success "OpenClaw $(openclaw --version 2>/dev/null || echo 'installed')"
  else
    info "Installing OpenClaw..."
    npm install -g openclaw
    success "OpenClaw installed"
  fi
}

# ============================================================
# Collect the ONE input
# ============================================================
collect_input() {
  echo ""
  echo -e "  ${BOLD}Almost there. Just one thing needed:${NC}"
  echo ""
  echo "  Open Telegram → search @BotFather → send /newbot"
  echo "  Give it any name and username, then copy the token."
  echo ""

  while true; do
    ask "Paste your Telegram bot token"
    read -r TELEGRAM_TOKEN
    if [[ "$TELEGRAM_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
      break
    else
      warn "Doesn't look right. Format: 123456789:ABCdef..."
    fi
  done
  echo ""

  ask "What should your AI call you? (default: Boss)"
  read -r USER_NAME
  USER_NAME="${USER_NAME:-Boss}"

  # Auto-detect timezone
  if [[ "$(uname)" == "Darwin" ]]; then
    TIMEZONE=$(systemsetup -gettimezone 2>/dev/null | awk -F': ' '{print $2}' || echo "UTC")
  else
    TIMEZONE=$(timedatectl show -p Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || echo "UTC")
  fi
  info "Timezone: $TIMEZONE"

  success "Got everything needed"
}

# ============================================================
# Deploy everything
# ============================================================
deploy() {
  info "Creating directory structure..."

  # Main workspace
  mkdir -p "$WORKSPACE_DIR"/{memory,tasks,templates,scripts,reference}
  mkdir -p "$WORKSPACE_DIR/tasks/done"

  # Sub-agent directories
  for agent in builder scout operator analyst; do
    mkdir -p "$OPENCLAW_DIR/agents/$agent/agent"
  done

  success "Directories created"

  # Copy workspace templates
  info "Deploying workspace files..."
  for f in SOUL.md AGENTS.md USER.md IDENTITY.md HEARTBEAT.md; do
    cp "$TEMPLATES/workspace/$f" "$WORKSPACE_DIR/$f"
  done
  cp "$TEMPLATES/workspace/templates/task-template.md" "$WORKSPACE_DIR/templates/task-template.md"
  success "Workspace files deployed"

  # Copy sub-agent configs
  info "Deploying sub-agent configs..."
  for agent in builder scout operator analyst; do
    cp "$TEMPLATES/agents/$agent/AGENTS.md" "$OPENCLAW_DIR/agents/$agent/agent/AGENTS.md"
  done
  success "Sub-agent configs deployed"

  # Replace placeholders in USER.md
  sed -i.bak "s/__USER_NAME__/$USER_NAME/g" "$WORKSPACE_DIR/USER.md"
  sed -i.bak "s|__TIMEZONE__|$TIMEZONE|g" "$WORKSPACE_DIR/USER.md"
  rm -f "$WORKSPACE_DIR/USER.md.bak"
  success "USER.md personalized"

  # Generate openclaw.json from template
  info "Generating config..."
  local gateway_secret
  gateway_secret=$(random_hex)

  cp "$TEMPLATES/openclaw.template.json" "$OPENCLAW_DIR/openclaw.json"
  sed -i.bak "s|__TELEGRAM_TOKEN__|$TELEGRAM_TOKEN|g" "$OPENCLAW_DIR/openclaw.json"
  sed -i.bak "s|__WORKSPACE_DIR__|$WORKSPACE_DIR|g" "$OPENCLAW_DIR/openclaw.json"
  sed -i.bak "s|__GATEWAY_SECRET__|$gateway_secret|g" "$OPENCLAW_DIR/openclaw.json"
  rm -f "$OPENCLAW_DIR/openclaw.json.bak"
  success "openclaw.json generated"

  # Create empty SESSION-STATE.md
  cat > "$WORKSPACE_DIR/SESSION-STATE.md" << 'SESSEOF'
# SESSION-STATE.md

## Active Task
None

## Recent Decisions
None yet

## Key Values
None yet
SESSEOF
  success "SESSION-STATE.md created"

  # Create MEMORY.md
  cat > "$WORKSPACE_DIR/MEMORY.md" << 'MEMEOF'
# MEMORY.md — Index

## Quick Status
- **Agent**: LeOpus 🦁
- **LLM**: Qwen3 8B (local, via Ollama)
- **Channel**: Telegram

## Drill-Down Directories

| Path | What's in it |
|------|-------------|
| `memory/` | Daily notes and topic breadcrumbs |
| `tasks/` | Active and completed tasks |
| `reference/` | Deep context, SOPs, playbooks |

## Active Work
None yet — send your first message on Telegram to get started!
MEMEOF
  success "MEMORY.md created"

  # Create TOOLS.md
  cat > "$WORKSPACE_DIR/TOOLS.md" << 'TOOLSEOF'
# TOOLS.md - Local Notes

Add environment-specific notes here: hostnames, device names, paths, etc.
This is your cheat sheet — skills are shared, this file is yours.
TOOLSEOF
  success "TOOLS.md created"

  # Set permissions
  chmod 600 "$OPENCLAW_DIR/openclaw.json"
  chmod 700 "$OPENCLAW_DIR"
  success "Permissions secured"
}

# ============================================================
# Start and verify
# ============================================================
start_and_verify() {
  info "Starting OpenClaw gateway..."
  openclaw gateway start

  # Give it a moment
  sleep 3

  if openclaw gateway status 2>/dev/null | grep -qi "running"; then
    success "Gateway is running"
  else
    warn "Gateway may still be starting. Check with: openclaw gateway status"
  fi

  echo ""
  echo -e "  ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${BOLD}🦁 LeOpus is alive!${NC}"
  echo ""
  echo -e "  Open Telegram and send a message to your bot."
  echo -e "  It's running Qwen3 8B locally — no API costs, ever."
  echo ""
  echo -e "  ${BOLD}Useful commands:${NC}"
  echo -e "    openclaw gateway status    — check if running"
  echo -e "    openclaw gateway restart   — restart"
  echo -e "    openclaw gateway stop      — stop"
  echo -e "    openclaw gateway logs      — view logs"
  echo ""
  echo -e "  ${BOLD}Your files:${NC}"
  echo -e "    $WORKSPACE_DIR/SOUL.md     — agent personality"
  echo -e "    $WORKSPACE_DIR/USER.md     — info about you"
  echo -e "    $WORKSPACE_DIR/MEMORY.md   — agent memory index"
  echo ""
  echo -e "  ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# ============================================================
# Main
# ============================================================
main() {
  banner

  # Verify templates exist
  [ -d "$TEMPLATES" ] || die "Templates not found. Run this from the clawdboss directory."

  echo -e "  ${BOLD}Step 1/6${NC} — Hardware check"
  check_hardware
  echo ""

  echo -e "  ${BOLD}Step 2/6${NC} — System dependencies"
  install_deps
  echo ""

  echo -e "  ${BOLD}Step 3/6${NC} — Ollama + Qwen3 8B"
  install_ollama
  echo ""

  echo -e "  ${BOLD}Step 4/6${NC} — OpenClaw"
  install_openclaw
  echo ""

  echo -e "  ${BOLD}Step 5/6${NC} — Your Telegram bot"
  collect_input
  echo ""

  echo -e "  ${BOLD}Step 6/6${NC} — Deploy & launch"
  deploy
  echo ""

  start_and_verify
}

main "$@"
