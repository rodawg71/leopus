# Customization Guide

## Changing Your Agent's Personality

Edit `~/.openclaw/workspace/SOUL.md`. This is the agent's core identity file — it defines personality, tone, and values.

## Adding Skills

OpenClaw has a skill marketplace. Browse and install:

```bash
# Search for skills
clawhub search "image generation"

# Install a skill
clawhub install openai-image-gen

# Configure the skill
openclaw config set skills.entries.openai-image-gen.apiKey '${OPENAI_API_KEY}'
```

## Adding More Discord Channels

1. Create the channel in Discord
2. Add it to your config:
```bash
openclaw config set channels.discord.guilds.YOUR_GUILD_ID.channels.NEW_CHANNEL_ID.allow true
```
3. Restart: `openclaw gateway restart`

## Binding an Agent to a Channel

Add a binding in `openclaw.json`:
```json
{
  "bindings": [
    {
      "agentId": "your-agent-id",
      "match": {
        "channel": "discord",
        "peer": {
          "kind": "channel",
          "id": "CHANNEL_ID"
        }
      }
    }
  ]
}
```

## Changing Models

```bash
# Set default model
openclaw config set agents.defaults.model.primary "provider/model-name"

# Set model for a specific agent
openclaw config set agents.list.1.model.primary "provider/model-name"
```

## Memory & Context

Clawdboss uses a three-tier memory architecture:

- **SESSION-STATE.md** — Active working memory (WAL target). The agent writes corrections, decisions, and important details here BEFORE responding. Think of it as the agent's RAM.
- **memory/YYYY-MM-DD.md** — Daily raw logs of what happened.
- **MEMORY.md** — Curated long-term memory. Distilled insights from daily logs. Create this manually when you want persistent context.

### WAL Protocol (Write-Ahead Log)

Your agents are pre-configured to use the WAL Protocol. When you tell an agent something important (a correction, a name, a decision), it writes that to `SESSION-STATE.md` before responding. This means the detail survives even if context compacts.

### Working Buffer

When context gets high (~60%), agents start logging every exchange to `memory/working-buffer.md`. After compaction, they read this buffer to recover. You never have to re-explain what you were working on.

### Heartbeat Tasks

Add periodic checks to `HEARTBEAT.md`. Keep it lean — each heartbeat burns tokens.

## Queue Tuning

The default config uses `interrupt` mode which is best for Discord (responds to latest message, drops stale ones). If you want to process all messages in order, change to `collect`:

```bash
openclaw config set messages.queue.mode "collect"
```
