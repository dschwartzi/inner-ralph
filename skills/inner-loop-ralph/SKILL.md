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
- `--dry-run` - Preview task breakdown without creating beads issues
- `--status` - Show progress of current/recent inner-ralph session
- `--cancel` - Stop a running inner-ralph session

## Instructions

<instruction>
You are starting an Inner Loop Ralph session - an AI-supervised autonomous workflow.

**Phase 0: Parse Arguments**

Check `$ARGUMENTS` for flags:
- `--dry-run`: If present, show proposed tasks WITHOUT creating beads issues, then stop
- `--status`: If present, run `bd list` and `bd stats`, show progress, then stop
- `--cancel`: If present, show current tasks and offer to stop/clean up, then stop

Extract the task description (everything that's not a flag).

If `--status` flag:
```
## Inner Ralph Status

[Run bd list to show current tasks]
[Run bd stats to show progress]

Subagent: [Check if any task is in_progress]
```
Then STOP - do not continue to other phases.

If `--cancel` flag:
```
## Cancel Inner Ralph

Current tasks:
[Run bd list]

Options:
- Close in-progress tasks as incomplete
- Delete all open tasks from this session
- Keep tasks for later

What would you like to do?
```
Then STOP after user responds.

If `--dry-run` flag: Continue to Phase 1 and 2, but in Phase 2 step 3,
do NOT actually run `bd create`. Instead, just OUTPUT what tasks WOULD be created.

**Phase 1: Initialize**

1. Parse the task description from `$ARGUMENTS` (excluding flags)
2. Check if beads is initialized:
   ```bash
   bd stats 2>/dev/null || bd init
   ```
3. If `bd init` was needed, commit the .beads/ directory
4. Check for guardrails file and read if present:
   ```bash
   cat plans/guardrails.md 2>/dev/null || cat .claude/guardrails.md 2>/dev/null
   ```
   Include guardrails in subagent prompt (Phase 3) to prevent repeated failures

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

   **If `--dry-run` mode:**
   Do NOT run `bd create`. Instead, output a preview:
   ```
   ## Dry Run Preview (no issues created)

   Would create the following tasks:

   | # | Title | Priority | Depends On |
   |---|-------|----------|------------|
   | 1 | [task title] | P[0-4] | - |
   | 2 | [task title] | P[0-4] | #1 |
   ...

   Run without --dry-run to create these tasks.
   ```
   Then STOP - do not continue to Phase 2.5 or Phase 3.

   **Normal mode:**
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

**Phase 2.5: Get User Approval**

Present the task breakdown to the user and ask for approval before executing:

```
## Proposed Task Breakdown

I've analyzed the project and created the following tasks:

[Show bd list output with task titles and dependencies]

**Summary:**
- Total tasks: N
- Ready to start: M (no blockers)
- Blocked: K (waiting on dependencies)

**Estimated approach:**
[Brief description of the implementation strategy]

Would you like me to proceed with this plan?
- **Yes** - Start autonomous execution
- **Modify** - Tell me what to change
- **Cancel** - Delete these tasks and stop
```

Wait for user response before proceeding:
- If "yes" or approved: Continue to Phase 3
- If modification requested: Update tasks with `bd update` or `bd delete` and `bd create`, then re-present
- If cancelled: Run `bd delete <all-task-ids>` and stop

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

## Proposed Task Breakdown

I've analyzed the project and created the following tasks:

| ID | Task | Priority | Blocked By |
|----|------|----------|------------|
| inner-ralph-a1b | Set up JWT dependencies | P0 | - |
| inner-ralph-c2d | Create auth middleware | P1 | a1b |
| inner-ralph-e3f | Add login/register endpoints | P1 | a1b |
| inner-ralph-g4h | Write auth tests | P2 | c2d, e3f |
| inner-ralph-i5j | Add protected route examples | P2 | c2d |

**Summary:** 5 tasks, 1 ready to start, 4 blocked

**Approach:** First install jsonwebtoken and bcrypt, then create middleware
for JWT verification, add auth endpoints, and finally add tests.

Would you like me to proceed with this plan?

User: yes

Claude: Starting autonomous execution...

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
