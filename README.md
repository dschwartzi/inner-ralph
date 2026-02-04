# Inner Loop Ralph

**Status: Tested & Working** | v1.1.0 | [Changelog](CHANGELOG.md) | [Dogfooding Example](examples/dogfooding-session.md)

AI-supervised autonomous agent loops for Claude Code using [beads](https://github.com/steveyegge/beads) for persistent task tracking.

## What is This?

Inner Loop Ralph turns vague requests into structured, executable plans. You describe what you want to accomplish, and Claude:

1. **Breaks it down** into concrete subtasks with dependencies
2. **Shows you the plan** for approval before doing anything
3. **Executes autonomously** while you supervise
4. **Persists state** so nothing gets lost if context compacts

It works for any multi-step work: coding, research, writing, analysis, organization - anything that benefits from structured task decomposition.

### Why Let Claude Create the Plan?

External Ralph implementations require you to manually write a `prd.json` file with task definitions. But Claude has become remarkably good at task decomposition:

- **Subagents enable decomposition** - Breaking large goals into smaller, safer pieces while keeping contexts clean ([source](https://skywork.ai/blog/claude-code-2-0-checkpoints-subagents-autonomous-coding/))
- **Goal-driven planning** - Claude autonomously decides what tools it needs and plans next actions based on current state ([source](https://www.startuphub.ai/ai-news/ai-video/2026/anthropics-agent-sdk-unlocks-autonomous-development/))
- **Structured breakdown** - With proper prompting, Claude can transform vague requirements into concrete, actionable task lists ([source](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents))

Inner Loop Ralph leverages this by having Claude analyze your request and generate the task breakdown automatically. You review and approve the plan before execution begins - getting the benefits of AI planning with human oversight.

```
External Ralph:  Bash Loop → Spawn Claude → Do Task → Exit → Repeat
Inner Ralph:     Claude Code → Create Tasks → Spawn Subagent → Supervise → Complete
```

## Key Features

- **AI-generated task breakdown** - Describe what you want; Claude creates the task graph
- **Approval before execution** - Review and modify the plan before any work begins
- **Beads for persistence** - Task state survives context compaction via git-backed `.beads/` directory
- **Intelligent orchestration** - Claude supervises subagents and can intervene when things go wrong
- **Natural intervention** - Talk to Claude to course-correct, no need to kill scripts
- **Built-in flags** - `--dry-run`, `--status`, `--cancel` for full control

## Installation

### Prerequisites

1. [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
2. [Beads](https://github.com/steveyegge/beads) installed (`bd` command)

**Quick beads install** (if you don't have it):
```bash
git clone https://github.com/dschwartzi/inner-ralph.git
./inner-ralph/scripts/setup.sh
```

### Install the Plugin (Choose One)

#### Option 1: Official Marketplace (Coming Soon)

Once approved, installation will be:
```
/plugin install inner-loop-ralph@claude-plugins-official
```
*(Submission pending - check back soon)*

#### Option 2: Copy the Skill Folder

Works right now:

```bash
git clone https://github.com/dschwartzi/inner-ralph.git
mkdir -p ~/.claude/skills
cp -r inner-ralph/skills/inner-loop-ralph ~/.claude/skills/
```

Restart Claude Code. The skill will be available as `/inner-loop-ralph`.

#### Option 3: Just Use the Prompt

Don't want to install anything? Copy the contents of [SKILL.md](skills/inner-loop-ralph/SKILL.md) into your `~/.claude/CLAUDE.md` file.

## Quick Start

```bash
# 1. Clone and install beads (if needed)
git clone https://github.com/dschwartzi/inner-ralph.git
./inner-ralph/scripts/setup.sh

# 2. Copy the skill to your Claude config
mkdir -p ~/.claude/skills
cp -r inner-ralph/skills/inner-loop-ralph ~/.claude/skills/

# 3. Restart Claude Code and try it
claude
/inner-loop-ralph --dry-run plan a birthday party
```

That's it. Three steps.

### What to Expect

The dry run shows what tasks *would* be created. The full flow will:
1. Initialize beads
2. Show you the task breakdown
3. Ask for your approval
4. Execute autonomously (if you approve)

## Usage

### Direct Invocation

After installing the plugin, invoke directly:

```
/inner-loop-ralph <describe what you want to accomplish>
```

### CLI Flags

```bash
# Preview task breakdown without creating issues
/inner-loop-ralph --dry-run <task description>

# Check progress of current session
/inner-loop-ralph --status

# Stop a running session
/inner-loop-ralph --cancel
```

### Example: Research Task

```
> /inner-loop-ralph research competitive landscape for AI coding assistants

Analyzing request...

## Proposed Task Breakdown

| ID | Task | Priority | Blocked By |
|----|------|----------|------------|
| inner-ralph-a1b | Identify major AI coding tools | P0 | - |
| inner-ralph-c2d | Research GitHub Copilot features | P1 | a1b |
| inner-ralph-e3f | Research Cursor features | P1 | a1b |
| inner-ralph-g4h | Research Codeium features | P1 | a1b |
| inner-ralph-i5j | Compare pricing models | P2 | c2d, e3f, g4h |
| inner-ralph-k6l | Write summary report | P2 | i5j |

**Summary:** 6 tasks, 1 ready to start, 5 blocked

Would you like me to proceed with this plan?

> yes

Starting autonomous execution...
[Subagent works through tasks]

Completed 6/6 tasks. Report ready at research/ai-coding-tools.md
```

### Example: Coding Task

```
> /inner-loop-ralph add user authentication with OAuth

Analyzing project...
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

### Example: Writing Task

```
> /inner-loop-ralph write a blog post about our new product launch

Analyzing request...

## Proposed Task Breakdown

| ID | Task | Priority | Blocked By |
|----|------|----------|------------|
| inner-ralph-a1b | Outline key product features | P0 | - |
| inner-ralph-c2d | Draft introduction hook | P1 | a1b |
| inner-ralph-e3f | Write feature sections | P1 | a1b |
| inner-ralph-g4h | Add customer quotes/testimonials | P1 | - |
| inner-ralph-i5j | Write conclusion and CTA | P2 | c2d, e3f, g4h |
| inner-ralph-k6l | Final review and polish | P2 | i5j |

**Summary:** 6 tasks, 2 ready to start, 4 blocked

Would you like me to proceed with this plan?
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
> Actually, focus on the enterprise features instead

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
| Task creation | Manual `prd.json` | AI-generated from your description |
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

1. **Parse Request** - Extract your task description and any flags (`--dry-run`, etc.)
2. **Initialize Beads** - Run `bd init` if not already set up
3. **Analyze & Plan** - Understand your goal, break it into subtasks, create beads issues with dependencies
4. **Get Approval** - Present the task breakdown and wait for your confirmation
5. **Execute** - Spawn a Task tool subagent to work through `bd ready` tasks
6. **Report** - Show completion status, remaining tasks, or blockers

### Architecture

```
┌─────────────────────────────────────────────┐
│            Claude Code (Orchestrator)        │
│                                              │
│  ┌──────────┐    ┌──────────┐               │
│  │ Analyze  │───▶│  Create  │               │
│  │ Request  │    │  Tasks   │               │
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
