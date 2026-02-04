# Inner Ralph: AI-Supervised Autonomous Agent Loops

> **Status**: Conceptual approach / reference implementation. This documents a workflow pattern, not a packaged tool.

An alternative approach to autonomous AI coding that uses **Claude Code as the orchestrator** instead of external bash scripts.

## The Problem with External Loops

Tools like [snarktank/ralph](https://github.com/snarktank/ralph) use a bash script to spawn fresh AI instances in a loop:

```
Bash Loop → Spawn Claude → Do Task → Exit → Repeat
```

This works, but has limitations:
- **Manual PRD**: You must write `prd.json` yourself
- **Dumb orchestration**: Bash doesn't understand your codebase
- **No supervision**: Can't intervene intelligently when things go wrong
- **No learning**: Each instance starts fresh with no accumulated insight

## The Inner Ralph Approach

What if Claude Code itself manages the loop?

```
Claude Code (Orchestrator)
    │
    ├── Analyzes codebase
    ├── Creates task breakdown (replaces manual PRD)
    ├── Spawns subagent for autonomous work
    │       │
    │       └── Works through tasks via beads
    │           ├── bd ready → pick task
    │           ├── implement
    │           ├── bd close → mark done
    │           └── repeat
    │
    └── Supervises, intervenes, course-corrects
```

### Key Advantages

| Feature | External Ralph | Inner Ralph |
|---------|---------------|-------------|
| Task creation | Manual PRD file | AI-generated from context |
| Orchestration | Dumb bash loop | Intelligent Claude supervision |
| Error handling | Fail and retry | Understand and adapt |
| Context | Fresh each time (loses insight) | Persistent via [beads](https://github.com/steveyegge/beads) |
| Intervention | Kill script, edit PRD | Natural conversation |
| Learning | `progress.txt` file | Accumulated context + beads comments |

### Why This Works

1. **AI understands the problem**: Claude reads your codebase and creates better task breakdowns than you would manually
2. **Supervised autonomy**: The outer Claude session can intervene when subagents get stuck
3. **Persistent state**: [Beads](https://github.com/steveyegge/beads) provides git-backed issue tracking that survives context compaction
4. **Course correction**: When something fails, Claude understands WHY and adjusts

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- [Beads](https://github.com/steveyegge/beads) for task tracking

### Usage

1. Start Claude Code in your project:
   ```bash
   claude
   ```

2. Tell Claude what you want to accomplish:
   ```
   > ralph: implement user authentication with OAuth
   ```

3. Claude will:
   - Analyze your codebase
   - Create beads issues for each subtask
   - Spawn an autonomous agent to work through them
   - Report back when complete (or blocked)

4. Check progress anytime:
   ```bash
   bd list
   bd ready
   bd show <issue-id>
   ```

### The "ralph:" Protocol

When you prefix a request with `ralph:`, Claude Code:

1. **Scans the project** - Understands structure, conventions, test setup
2. **Creates task graph** - Breaks work into beads issues with dependencies
3. **Executes autonomously** - Works through `bd ready` tasks
4. **Reports back** - Only interrupts when genuinely blocked

## Example Session

```
> ralph: optimize this kernel to run in fewer cycles

Analyzing codebase...
Found: VLIW SIMD architecture simulator
Current: 3,377 cycles
Target: < 1,487 cycles

Creating tasks:
  ✓ speed-001: Implement SIMD vectorization
  ✓ speed-002: Add batch-level pipelining
  ✓ speed-003: Optimize hash instruction packing
  → speed-004: Cross-round pipeline overlap (blocked by 003)
  → speed-005: Beat target threshold (blocked by 004)

Starting autonomous execution...

[2 hours later]

Completed: 2,710 cycles (54.5x speedup)
Remaining: speed-004, speed-005 need architectural decision

Should I continue with cross-round pipelining, or would you
prefer a different approach?
```

## How It Handles Context Limits

When Claude's context fills up:

1. **Conversation compacts** - Old messages summarized
2. **Beads persists** - All task state survives in `.beads/`
3. **Run `bd prime`** - Recovers full context from beads
4. **Continue seamlessly** - Pick up exactly where you left off

This is the key insight: you don't need fresh instances if your state persists properly.

## Comparison

### When to use External Ralph (snarktank/ralph)
- Very long-running tasks (days)
- You want completely hands-off execution
- Simple, well-defined PRD
- Don't need intelligent intervention

### When to use Inner Ralph
- Complex tasks requiring judgment
- You want to supervise and intervene
- Task breakdown is non-obvious
- You value AI-generated planning
- Context persistence via beads is acceptable

## Technical Implementation

Inner Ralph leverages two key Claude Code capabilities:

### 1. The Task Tool (Subagents)

Claude Code can spawn autonomous subagents using the `Task` tool. These subagents:
- Run in the background with their own context
- Have access to all the same tools (Bash, Read, Edit, etc.)
- Report back to the orchestrator when complete or blocked
- Can be monitored via `TaskOutput`

```
Orchestrator                    Subagent
    │                              │
    │──── Task(prompt) ───────────▶│
    │                              │ works autonomously
    │                              │ bd ready → implement
    │                              │ bd close → repeat
    │◀─── Result ─────────────────│
    │                              │
    ▼                              ▼
 supervise                     execute
```

### 2. Beads for Persistent State

[Beads](https://github.com/steveyegge/beads) is a git-backed issue tracker that:
- Stores task state in `.beads/` directory (committed to git)
- Survives context compaction (unlike conversation memory)
- Supports dependencies (`bd dep add`)
- Provides `bd ready` to find unblocked tasks
- Recovers full context via `bd prime`

### The Key Insight

External Ralph (bash loop) uses **file I/O** for state:
- `prd.json` - task definitions
- `progress.txt` - learnings

Inner Ralph uses **git-backed structured data**:
- `.beads/` - task state with dependencies, comments, history
- `bd` commands - query and update tasks
- Git sync - state travels with the repo

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Claude Code                        │
│                  (Orchestrator)                      │
│                                                      │
│  ┌─────────────┐    ┌─────────────┐                │
│  │   Analyze   │───▶│   Create    │                │
│  │  Codebase   │    │   Tasks     │                │
│  └─────────────┘    └──────┬──────┘                │
│                            │                        │
│                            ▼                        │
│                    ┌──────────────┐                 │
│                    │    Beads     │                 │
│                    │  (bd ready)  │◀────┐          │
│                    └──────┬───────┘     │          │
│                           │             │          │
│                           ▼             │          │
│                    ┌──────────────┐     │          │
│                    │   Subagent   │     │          │
│                    │  (Task tool) │─────┘          │
│                    └──────────────┘   bd close     │
│                                                     │
│  Supervise ◀──────────────────────────▶ Intervene  │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
                    ┌──────────┐
                    │   Git    │
                    │ (state)  │
                    └──────────┘
```

## Setup

To enable the `ralph:` protocol in your Claude Code sessions, add this to your `~/.claude/CLAUDE.md`:

```markdown
## Ralph Protocol (Autonomous Mode)

When the user says `ralph: [description]` or `ralph [description]`:

1. **Project Scan** - Check for package.json, requirements.txt, etc.
2. **Quick Context Check** - Ask ONE clarifying question if ambiguous
3. **Initialize Beads** - Run `bd init` if not already set up
4. **Generate Task Graph** - Create beads issues with dependencies
5. **Execute Autonomously** - Work through `bd ready` tasks
6. **Report Back** - Only interrupt when blocked or complete
```

## Contributing

This is an experimental approach. Share your experience:
- Star the repo if you find this useful
- Fork and experiment with your own variations
- Discuss on Twitter/X with #InnerRalph

## References

- [Geoffrey Huntley's Original Ralph](https://ghuntley.com/ralph/) - The canonical origin story
- [snarktank/ralph](https://github.com/snarktank/ralph) - Ryan Carson's implementation
- [beads](https://github.com/steveyegge/beads) - Steve Yegge's git-backed issue tracker
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) - Anthropic's CLI
- [Anthropic: Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Engineering best practices

## Credits

- Inspired by [snarktank/ralph](https://github.com/snarktank/ralph) and Ryan Carson's Ralph Wiggum technique
- Uses [beads](https://github.com/steveyegge/beads) by Steve Yegge for persistent task tracking
- Built for [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## License

MIT
