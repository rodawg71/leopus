<div align="center">

# 🦁 LeOpus

**Battle-tested AI assistant. One command. One token. Zero cost.**

A pre-configured [OpenClaw](https://github.com/openclaw/openclaw) setup with a 5-agent hierarchy,
task lifecycle management, and execution discipline — running entirely on local hardware.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

## What You Get

- **5-agent hierarchy** — Main orchestrator + Builder, Scout, Operator, Analyst
- **Local LLM** — Qwen2.5 7B via Ollama. No API keys. No monthly bills. Ever.
- **Telegram interface** — Talk to your AI from your phone
- **Task lifecycle** — Every multi-step job gets tracked, checkpointed, and verified
- **Compaction survival** — Agent recovers context after memory resets
- **Heartbeat monitoring** — Periodic system health checks
- **Execution discipline** — No hallucinated completions. Proof or it didn't happen.

## Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 16 GB | 32 GB+ |
| GPU | None (CPU works) | NVIDIA or Apple Silicon |
| OS | macOS or Ubuntu/Debian | Any with bash + Node.js |
| Disk | 10 GB free | 20 GB free |

## Quick Start

```bash
git clone https://github.com/rodawg71/leopus.git
cd leopus
./setup-leopus.sh
```

The installer handles everything:

1. **Hardware check** — validates RAM and detects GPU
2. **Node.js** — installs v22+ if missing
3. **Ollama** — installs and pulls Qwen2.5 7B (~5GB download)
4. **OpenClaw** — installs via npm
5. **Your token** — paste your Telegram bot token (the only input)
6. **Deploy** — copies configs, generates secrets, starts the gateway

Then open Telegram and message your bot.

### Get a Telegram Bot Token

1. Open Telegram → search **@BotFather**
2. Send `/newbot`
3. Choose a name and username
4. Copy the token

That's it. That's the only thing you need.

## Architecture

```
You (Telegram) → LeOpus (Main Agent)
                    ├── Builder   — writes code, creates files
                    ├── Scout     — researches, fetches info
                    ├── Operator  — browser automation, system ops
                    └── Analyst   — data analysis, summaries
```

LeOpus (main) never executes directly — it plans, delegates to sub-agents,
and verifies results. Think CEO, not intern.

## Key Files

After install, your workspace lives at `~/.openclaw/workspace/`:

| File | Purpose |
|------|---------|
| `SOUL.md` | Agent personality, values, execution rules |
| `AGENTS.md` | Boot sequence, task lifecycle, write discipline |
| `USER.md` | Info about you (name, timezone) |
| `IDENTITY.md` | Agent identity |
| `MEMORY.md` | Memory index |
| `HEARTBEAT.md` | Automated health check schedule |
| `templates/task-template.md` | Template for multi-step tasks |

Everything is plain Markdown. Edit any file to customize behavior.

## Commands

```bash
openclaw gateway status     # check if running
openclaw gateway restart    # restart
openclaw gateway stop       # stop
openclaw gateway logs       # view logs
```

## What Makes This Different

Most AI setups are a model behind an API. LeOpus is an **opinionated system**
built from months of real-world usage:

- **Truth over agreement** — it will push back if you're wrong
- **Proof rule** — every claim of completion includes evidence
- **Write discipline** — all file writes are chunked and verified
- **Loop detection** — catches itself if stuck in reasoning loops
- **No completion theater** — never says "done" without proof

## Customization

### Change the LLM

Edit `~/.openclaw/openclaw.json` — swap `qwen2.5:7b` for any Ollama model:

```bash
ollama pull llama3:8b          # Meta Llama 3
ollama pull mistral:7b         # Mistral
ollama pull deepseek-v3:8b     # DeepSeek
```

Or point to a cloud provider (OpenAI, Anthropic, etc.) by updating the
`providers` section in `openclaw.json`.

### Add Skills

```bash
openclaw skills install <skill-name>
```

Browse available skills at [clawhub.com](https://clawhub.com).

### Change Personality

Edit `~/.openclaw/workspace/SOUL.md`. It's just Markdown.
Want a friendlier assistant? A stricter one? A pirate? Change the file.

## FAQ

**Q: Is this really free?**
Yes. Ollama is open source. Qwen2.5 is open weight. OpenClaw is open source.
The only cost is the electricity to run your machine.

**Q: How much VRAM does it need?**
Qwen2.5 7B needs ~5GB. Works on most NVIDIA cards (GTX 1060+) and all Apple Silicon.
CPU-only works too, just slower.

**Q: Can I use a cloud LLM instead?**
Yes. Edit openclaw.json to add OpenAI, Anthropic, or any OpenAI-compatible API.

**Q: What about privacy?**
Everything runs locally by default. Your conversations never leave your machine
unless you configure a cloud provider.

## Credits

Built by [@rodawg71](https://github.com/rodawg71), evolved through daily use
with [OpenClaw](https://github.com/openclaw/openclaw).

Based on [clawdboss](https://github.com/NanoFlow-io/clawdboss) by NanoFlow-io.

## License

MIT
