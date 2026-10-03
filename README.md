# Agent skills

Reusable [Agent Skills](https://agentskills.io/) for software engineering and productivity. Browse the [skill catalog](SKILLS.md) to find a skill.

| Directory | Skills |
|---|---|
| [`skills/engineering/`](skills/engineering/) | Planning, research, software design, implementation, testing, and code review. |
| [`skills/productivity/`](skills/productivity/) | Decision-making, agent instructions, writing, and model routing. |

## Install

### Requirements

- [Node.js](https://nodejs.org/) and npm.
- Git, with access to this GitHub repository.
- A supported coding agent, such as OpenCode, GitHub Copilot, Codex, or Claude Code.

### Install the skills

```bash
npx skills@latest add grauzone-dev/agent-skills
```

The CLI lists the skills in this repository; select the ones you want. Without further parameters it detects the coding agents installed on your machine and asks where to install.

#### `--global`

Add `--global` to install for your user account, making the skills available in every project. Without it, the CLI installs into the current project: run the command from the project directory and choose **Project** when asked for the installation scope.

#### `--agent`

Add `--agent <identifier>` to target one agent explicitly. This skips installation attempts for other agents, such as PromptScript, which supports project-level installation only.

| Agent | Identifier |
|---|---|
| Claude Code | `claude-code` |
| OpenAI Codex | `codex` |
| GitHub Copilot | `github-copilot` |
| OpenCode | `opencode` |

For example, this installs the skills for Claude Code at user level:

```bash
npx skills@latest add grauzone-dev/agent-skills --global --agent claude-code
```

See the [supported agents](https://github.com/vercel-labs/skills#supported-agents) for further identifiers.

### Install a specific skill

Add `--skill <name>` to select a skill directly. Add `--yes` to skip prompts. For example, this installs `research` for OpenCode in the current project:

```bash
npx skills@latest add grauzone-dev/agent-skills --skill research --agent opencode --yes
```

Replace `research` with a skill name from the [catalog](SKILLS.md) and `opencode` with your agent's identifier. Add `--global` for a user-level installation.

## Update or remove skills

Run these commands from the project where you installed the skills:

```bash
npx skills@latest update
npx skills@latest remove
```

The CLI guides you through choosing which installed skills to update or remove. Add `--global` to target a user-level installation.

## About skills

Each skill is a directory containing a `SKILL.md` file and, when needed, supporting files. Review a skill before installing it. Skills provide instructions to an AI agent and may reference tools or actions in your environment.

## References

- [Skill catalog](SKILLS.md)
- [Agent Skills specification](https://agentskills.io/specification)
- [Skills CLI](https://github.com/vercel-labs/skills)
- [Supported agents](https://github.com/vercel-labs/skills#supported-agents)
