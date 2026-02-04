# Inner Loop Ralph

**Status: Tested & Working** | v1.1.0 | [Changelog](CHANGELOG.md) | [Dogfooding Example](examples/dogfooding-session.md)

AI-supervised autonomous agent loops for Claude Code using [beads](https://github.com/steveyegge/beads) for persistent task tracking.

## What is This?

Inner Loop Ralph is an alternative to external bash-based automation (like [snarktank/ralph](https://github.com/snarktank/ralph)). Instead of spawning fresh Claude instances from a bash loop, it uses **Claude Code itself as the intelligent orchestrator**.

### Why Let Claude Create the PRD?

External Ralph implementations require you to manually write a `prd.json` file with task definitions. But Claude has become remarkably good at task decomposition:

- **Subagents enable decomposition** - Breaking large goals into smaller, safer pieces while keeping contexts clean ([source](https://skywork.ai/blog/claude-code-2-0-checkpoints-subagents-autonomous-coding/))
- **Goal-driven planning** - Claude autonomously decides what tools it needs and plans next actions based on current state ([source](https://www.startuphub.ai/ai-news/ai-video/2026/anthropics-agent-sdk-unlocks-autonomous-development/))
- **Structured breakdown** - With proper prompting, Claude can transform vague requirements into concrete, testable feature lists ([source](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents))

Inner Loop Ralph leverages this by having Claude analyze your codebase and generate the task breakdown automatically. You can review and approve the plan before execution begins - getting the benefits of AI planning with human oversight.

```
External Ralph:  Bash Loop → Spawn Claude → Do Task → Exit → Repeat
Inner Ralph:     Claude Code → Create Tasks → Spawn Subagent → Supervise → Complete
```

## Key Features

- **AI-generated task breakdown** - Claude analyzes your codebase and creates the task graph (no manual PRD needed)
- **Approval before execution** - Review and modify the plan before any work begins
- **Beads for persistence** - Task state survives context compaction via git-backed `.beads/` directory
- **Intelligent orchestration** - Claude supervises subagents and can intervene when things go wrong
- **Natural intervention** - Talk to Claude to course-correct, no need to kill scripts
- **Built-in flags** - `--dry-run`, `--status`, `--cancel` for full control

## Installation

### Prerequisites

1. [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
2. [Beads](https://github.com/steveyegge/beads) installed (`bd` command available)

### Install the Plugin

```bash
# Install from GitHub
/plugin install dschwartzi/inner-ralph
```

Or for local development:

```bash
# Clone and install locally
git clone https://github.com/dschwartzi/inner-ralph.git
/plugin install /path/to/inner-ralph
```

## Usage

### Direct Invocation

After installing the plugin, invoke directly:

```
/inner-loop-ralph implement user authentication with OAuth
```

### CLI Flags

```bash
# Preview task breakdown without creating issues
/inner-loop-ralph --dry-run implement auth

# Check progress of current session
/inner-loop-ralph --status

# Stop a running session
/inner-loop-ralph --cancel
```

### Example Session (with Approval)

```
> /inner-loop-ralph add user authentication

Analyzing codebase...
Found: Express.js API
Test command: npm test

## Proposed Task Breakdown

| ID | Task | Priority | Blocked By |
|----|------|----------|------------|
| inner-ralph-a1b | Set up auth dependencies | P0 | - |
| inner-ralph-c2d | Create auth middleware | P1 | a1b |
| inner-ralph-e3f | Add login/register endpoints | P1 | a1b |
| inner-ralph-g4h | Write integration tests | P2 | c2d, e3f |

**Summary:** 4 tasks, 1 ready to start, 3 blocked

Would you like me to proceed with this plan?

> yes

Starting autonomous execution...
[Subagent works through tasks]

Completed 4/4 tasks. All tests passing.
```

### Enable `ralph:` Protocol (Optional)

To use the `ralph:` prefix, add this to your `~/.claude/CLAUDE.md`:

```markdown
## Ralph Protocol

When the user says `ralph: [description]`:
1. Invoke: /inner-loop-ralph [description]
```

### Monitor Progress

While the subagent works:

```bash
bd list          # See all tasks
bd ready         # See available work
bd show <id>     # See task details
bd stats         # Overall progress
```

### Intervene

Just talk to Claude:

```
> The OAuth flow should use PKCE, not implicit flow

Got it. Let me update the approach...
[Updates tasks and continues]
```

### Context Recovery

If Claude's context compacts:

```bash
bd prime         # Recovers full context from beads
```

Then continue seamlessly - all task state is preserved in `.beads/`.

## Comparison

| Feature | External Ralph | Inner Loop Ralph |
|---------|---------------|------------------|
| Task creation | Manual `prd.json` | AI-generated from context |
| Loop mechanism | Bash script | Task tool subagent |
| State persistence | `progress.txt` file | Git-backed beads |
| Orchestration | Dumb loop | Intelligent supervision |
| Intervention | Kill script, edit PRD | Natural conversation |
| Error handling | Retry | Understand and adapt |

### When to use External Ralph
- Very long runs (days) where you want hands-off execution
- Simple, well-defined PRD that doesn't need AI planning
- You prefer fresh context each iteration

### When to use Inner Loop Ralph
- Complex tasks requiring judgment
- Task breakdown is non-obvious
- You want to supervise and intervene
- Context persistence via beads is acceptable

## How It Works

1. **Parse Request** - Extract the task description and any flags (`--dry-run`, etc.)
2. **Initialize Beads** - Run `bd init` if not already set up
3. **Analyze & Plan** - Scan project, break work into subtasks, create beads issues with dependencies
4. **Get Approval** - Present the task breakdown and wait for user confirmation
5. **Execute** - Spawn a Task tool subagent to work through `bd ready` tasks
6. **Report** - Show completion status, remaining tasks, or blockers

### Architecture

```
┌─────────────────────────────────────────────┐
│            Claude Code (Orchestrator)        │
│                                              │
│  ┌──────────┐    ┌──────────┐               │
│  │ Analyze  │───▶│  Create  │               │
│  │ Codebase │    │  Tasks   │               │
│  └──────────┘    └────┬─────┘               │
│                       │                      │
│                       ▼                      │
│               ┌──────────────┐              │
│               │    Beads     │◀────┐        │
│               │  (bd ready)  │     │        │
│               └──────┬───────┘     │        │
│                      │             │        │
│                      ▼             │        │
│               ┌──────────────┐     │        │
│               │   Subagent   │─────┘        │
│               │  (Task tool) │  bd close    │
│               └──────────────┘              │
│                                              │
│  Supervise ◀────────────────▶ Intervene    │
└─────────────────────────────────────────────┘
                     │
                     ▼
               ┌──────────┐
               │   Git    │
               │ (.beads) │
               └──────────┘
```

## Beads Commands Reference

| Command | Purpose |
|---------|---------|
| `bd init` | Initialize beads in project |
| `bd ready` | Show tasks with no blockers |
| `bd list` | Show all open tasks |
| `bd show <id>` | Show task details |
| `bd close <id>` | Mark task complete |
| `bd prime` | Recover context after compaction |
| `bd stats` | Project statistics |
| `bd sync` | Sync with git remote |

## References

- [Geoffrey Huntley's Original Ralph](https://ghuntley.com/ralph/) - The canonical origin story
- [snarktank/ralph](https://github.com/snarktank/ralph) - Ryan Carson's implementation
- [beads](https://github.com/steveyegge/beads) - Steve Yegge's git-backed issue tracker
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) - Anthropic's CLI
- [Anthropic: Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Engineering best practices

## Contributing

- Star the repo if you find this useful
- Fork and experiment with your own variations
- Issues and PRs welcome

## License

MIT
