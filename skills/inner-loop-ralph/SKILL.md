---
name: inner-loop-ralph
description: AI-supervised autonomous agent loops using beads for task tracking. Triggered by "ralph:" prefix. Use when user wants autonomous multi-task execution with intelligent orchestration.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, TaskOutput
argument-hint: "<description of work to accomplish>"
---

# Inner Loop Ralph - AI-Supervised Autonomous Agent

Launch an AI-supervised autonomous loop that uses beads for task tracking and the Task tool for subagent execution.

## When This Activates

- User says `ralph: <description>` or `ralph <description>`
- User wants autonomous multi-task execution
- User needs Claude to break down and execute complex work

## How It Differs from External Ralph

| Aspect | External Ralph | Inner Loop Ralph |
|--------|---------------|------------------|
| Loop mechanism | External bash script | Task tool subagent |
| Task tracking | prd.json file | beads (bd commands) |
| Orchestration | Dumb bash loop | Intelligent Claude supervision |
| Context | Fresh each iteration | Persistent via beads |
| Intervention | Kill script | Natural conversation |

## Arguments

- `$ARGUMENTS` - Description of what to accomplish

## Instructions

<instruction>
You are starting an Inner Loop Ralph session - an AI-supervised autonomous workflow.

**Phase 1: Initialize**

1. Parse the task description from `$ARGUMENTS`
2. Check if beads is initialized:
   ```bash
   bd stats 2>/dev/null || bd init
   ```
3. If `bd init` was needed, commit the .beads/ directory

**Phase 2: Analyze & Plan**

1. Scan the project to understand:
   - Project type (package.json, requirements.txt, go.mod, etc.)
   - Test command (npm test, pytest, go test, etc.)
   - Existing structure and conventions

2. Break down the task into subtasks:
   - Each subtask should be independently completable
   - Identify dependencies between subtasks
   - Aim for 3-7 subtasks (not too granular, not too broad)

3. Create beads issues for each subtask:
   ```bash
   bd create --title="<subtask title>" --type=task --priority=<0-4> --description="<detailed description with acceptance criteria>"
   ```

4. Set up dependencies between tasks:
   ```bash
   bd dep add <blocked-task> <blocking-task>
   ```

5. Show the user the task breakdown:
   ```bash
   bd list
   bd blocked  # Show dependency graph
   ```

**Phase 3: Execute via Subagent**

1. Spawn a background subagent using the Task tool:
   ```
   Task(
     subagent_type: "beads:task-agent",
     prompt: "Work through all ready tasks using `bd ready`. For each task: claim it with `bd update <id> --status=in_progress`, implement it, verify with tests, then close with `bd close <id>`. Continue until no tasks remain or you get blocked.",
     run_in_background: true
   )
   ```

2. If beads:task-agent is not available, use general-purpose agent:
   ```
   Task(
     subagent_type: "general-purpose",
     prompt: "You are in an Inner Ralph loop. Work through tasks using beads:

     1. Run `bd ready` to find unblocked tasks
     2. Pick the first ready task
     3. Run `bd update <id> --status=in_progress` to claim it
     4. Implement the task (read files, write code, run tests)
     5. When complete, run `bd close <id>`
     6. Repeat from step 1 until `bd ready` returns no tasks

     If you get stuck, describe the blocker and stop.

     Current project: [include relevant context]
     Verification command: [test command]",
     run_in_background: true
   )
   ```

3. Report to user that autonomous execution has started:
   ```
   Started autonomous execution. Monitor progress with:
   - `bd list` - See all tasks
   - `bd ready` - See available work
   - `bd show <id>` - See task details

   I'll report back when complete or blocked.
   ```

**Phase 4: Monitor & Report**

1. When the subagent completes, check results:
   ```bash
   bd list --status=all
   bd stats
   ```

2. Report final status to user:
   - Tasks completed
   - Tasks remaining (if any)
   - Any blockers encountered

**Error Handling**

- If beads commands fail, check with `bd doctor`
- If subagent gets stuck, offer to intervene
- If user interrupts, show current state with `bd list`

**Key Commands Reference**

| Command | Purpose |
|---------|---------|
| `bd init` | Initialize beads in project |
| `bd create --title="..." --type=task` | Create a task |
| `bd dep add <blocked> <blocker>` | Set dependency |
| `bd ready` | Show tasks with no blockers |
| `bd update <id> --status=in_progress` | Claim a task |
| `bd close <id>` | Mark task complete |
| `bd list` | Show all open tasks |
| `bd stats` | Project statistics |
| `bd prime` | Recover context after compaction |

</instruction>

## Example Session

```
User: ralph: add user authentication with JWT

Claude: Analyzing project...
Found: Express.js API (package.json)
Test command: npm test

Creating task breakdown:
  inner-ralph-a1b: Set up JWT dependencies (P0)
  inner-ralph-c2d: Create auth middleware (P1, blocked by a1b)
  inner-ralph-e3f: Add login/register endpoints (P1, blocked by a1b)
  inner-ralph-g4h: Write auth tests (P2, blocked by c2d, e3f)
  inner-ralph-i5j: Add protected route examples (P2, blocked by c2d)

Starting autonomous execution...

[Spawns subagent]

[Later]

Completed 5/5 tasks:
  ✓ inner-ralph-a1b: Set up JWT dependencies
  ✓ inner-ralph-c2d: Create auth middleware
  ✓ inner-ralph-e3f: Add login/register endpoints
  ✓ inner-ralph-g4h: Write auth tests
  ✓ inner-ralph-i5j: Add protected route examples

All tests passing. Authentication system ready.
```

## Context Recovery

If context gets compacted mid-session:
1. Run `bd prime` to recover beads context
2. Run `bd list` to see current state
3. Continue from where you left off

## Related

- [beads](https://github.com/steveyegge/beads) - Git-backed issue tracker
- [snarktank/ralph](https://github.com/snarktank/ralph) - External Ralph implementation
