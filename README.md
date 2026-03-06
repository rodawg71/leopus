# 🦞 Clawdboss

**Pre-hardened, multi-agent OpenClaw setup by NanoFlow.**

One script to go from zero to a fully secured, multi-agent AI assistant on Discord — with prompt injection defense, security auditing, WAL Protocol for context persistence, and best practices baked in.

## What You Get

- **Multi-agent architecture** — Main agent + optional specialist agents (Comms, Research, Security)
- **Security-first** — Prompt injection defense, anti-loop rules, content tagging, credential isolation
- **WAL Protocol** — Write-Ahead Log for corrections, decisions, and details that survive context loss
- **Working Buffer** — Danger zone logging to survive context compaction without losing work
- **Discord integration** — Bot bound to your server with channel-per-agent routing
- **Env-based secrets** — All API keys in `.env`, never in config files
- **Automated security audits** — Sentinel agent runs scheduled hardening checks
- **OCTAVE protocol** — Structured AI communication with 3-20x token compression (optional)

## Quick Start

```bash
# 1. Clone this repo
git clone git@github.com:NanoFlow-io/clawdboss.git
cd clawdboss

# 2. Install OpenClaw (if not already installed)
curl -fsSL https://openclaw.ai/install.sh | bash

# 3. Run the setup wizard
./setup.sh
```

The setup wizard will:
1. Prompt for your API keys and Discord credentials
2. Create your `.env` file (gitignored, never committed)
3. Generate `openclaw.json` with `${VAR}` references to your `.env`
4. Create agent workspaces with security rules + WAL Protocol pre-baked
5. Optionally install OCTAVE MCP server for structured document compression
6. Start the gateway

## Configuration Tiers

| Tier | Agents | Best For |
|------|--------|----------|
| **Solo** | Main only | Personal assistant, simple setups |
| **Team** | Main + 1-2 specialists | Small business, multiple workflows |
| **Full Squad** | Main + Comms + Research + Security | Full operations center |

## File Structure

```
clawdboss/
├── README.md
├── setup.sh                    # Interactive setup wizard
├── .env.example                # Template showing required variables
├── .gitignore                  # Protects secrets
├── templates/
│   ├── openclaw.template.json  # Config with ${VAR} placeholders
│   ├── workspace/              # Main agent workspace files
│   │   ├── AGENTS.md           # Operating rules + WAL Protocol + security
│   │   ├── SOUL.md
│   │   ├── USER.md
│   │   ├── TOOLS.md
│   │   ├── IDENTITY.md
│   │   └── HEARTBEAT.md
│   └── agents/                 # Specialist agent templates
│       ├── comms/
│       ├── research/
│       └── security/
└── docs/
    ├── security.md             # Security architecture + WAL Protocol overview
    ├── customization.md        # How to customize your setup
    └── octave.md               # OCTAVE protocol guide
```

## Context Persistence (WAL Protocol)

Clawdboss agents don't lose your corrections and decisions when context resets:

- **SESSION-STATE.md** — Agent writes important details here BEFORE responding (Write-Ahead Log)
- **Working Buffer** — At ~60% context, every exchange is logged to survive compaction
- **Compaction Recovery** — Agent reads buffer + state files after context loss, never asks "what were we doing?"

See [docs/security.md](docs/security.md) for the full architecture.

## Security

All API keys are stored in `~/.openclaw/.env` and referenced via `${VAR_NAME}` syntax in the config. Keys never appear in JSON config files.

All agents come with:
- Prompt injection defense (content isolation, pattern detection)
- Anti-loop rules (prevent token-burning attacks)
- External content security (emails, web pages treated as data-only)
- Relentless resourcefulness + VBR (Verify Before Reporting)

See [docs/security.md](docs/security.md) for the full security architecture.

## Requirements

- Node.js 22+
- A Discord bot token ([create one here](https://discord.com/developers/applications))
- An LLM provider (GitHub Copilot, OpenAI, Anthropic, or others)
- Optional: Brave Search API key, ElevenLabs API key

## License

Private — NanoFlow internal use only.
