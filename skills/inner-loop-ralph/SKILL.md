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
- `--status` - Show progress of current/recent inner-ralph session
- `--cancel` - Stop a running inner-ralph session

## Instructions

<instruction>
You are starting an Inner Loop Ralph session - an AI-supervised autonomous workflow.

## ⛔ MANDATORY CONSTRAINTS - VIOLATION IS FAILURE ⛔

**These rules are absolute. Breaking them means the skill failed.**

1. You MUST NOT spawn any Task/subagent until Phase 2.5 approval is received
2. You MUST show the proposed task breakdown and WAIT for user response
3. You MUST output the EXACT approval prompt format specified in Phase 2.5
4. Skipping ANY phase is a protocol violation
5. "Just doing it directly" without approval is NEVER acceptable when this skill is invoked

---

**Phase 0: Parse Arguments & Task Type Check**

Check `$ARGUMENTS` for flags:
- `--status`: If present, run `bd list` and `bd stats`, show progress, then STOP
- `--cancel`: If present, show current tasks and offer to stop/clean up, then STOP

Extract the task description (everything that's not a flag).

If `--status` flag, output:
```
## 📊 Inner Ralph Status

[Run bd list to show current tasks]
[Run bd stats to show progress]

Subagent: [Check if any task is in_progress]
```
Then STOP - do not continue to other phases.

If `--cancel` flag, output:
```
## ❌ Cancel Inner Ralph

Current tasks:
[Run bd list]

Options:
- Close in-progress tasks as incomplete
- Delete all open tasks from this session
- Keep tasks for later

What would you like to do?
```
Then STOP after user responds.

**Task Type Check (Escape Hatch):**

If the request appears to be simple exploration or research that doesn't need multi-step task tracking (e.g., "understand this codebase", "come up to speed", "find where X is implemented", "explain how Y works"), you MUST ask:

```
## 🤔 Task Type Check

This looks like a research/exploration task rather than multi-step implementation work.

**Should I:**
1. **Use full Ralph workflow** - Create beads tasks, show plan, get approval, execute via subagent
2. **Just explore directly** - Search/read files and report back without task overhead

Which approach do you prefer?
```

Then STOP and WAIT for user response.
- If user chooses option 1: Continue to Phase 1
- If user chooses option 2: Do the exploration directly WITHOUT using this skill's workflow

---

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

---

**Phase 2: Analyze & Plan**

1. Scan the project to understand:
   - Project type (package.json, requirements.txt, go.mod, etc.)
   - Test command (npm test, pytest, go test, etc.)
   - Existing structure and conventions

2. Break down the task into subtasks:
   - Each subtask should be independently completable
   - Identify dependencies between subtasks
   - Aim for 3-7 subtasks (not too granular, not too broad)

3. **DO NOT create beads issues yet.** First, show the proposed plan to the user.

---

**Phase 2.5: ⏸️ MANDATORY APPROVAL GATE**

**You MUST output this EXACT format before creating any beads issues or spawning any subagent:**

```
---
## ⏸️ Awaiting Your Approval

**Proposed tasks:**

| # | Task | Priority | Depends On |
|---|------|----------|------------|
| 1 | [task title] | P[0-4] | - |
| 2 | [task title] | P[0-4] | #1 |
...

**Summary:**
- Total tasks: N
- Ready to start: M (no blockers)
- Blocked: K (waiting on dependencies)

**Approach:**
[Brief description of the implementation strategy]

---

**Proceed with this plan?**
- Reply **"yes"** or **"go"** to create tasks and start execution
- Reply with **modifications** to adjust the plan
- Reply **"cancel"** to abort

---
```

**Then STOP. Do not send another message. Do not use any tools. WAIT for user response.**

After user responds:
- If "yes", "go", or approved: Continue to Phase 2.6 (Create Tasks)
- If modification requested: Adjust the plan and re-present Phase 2.5
- If "cancel": Output "Cancelled. No tasks created." and STOP

---

**Phase 2.6: Create Tasks**

Only after receiving approval, create the beads issues:

```bash
bd create --title="<subtask title>" --type=task --priority=<0-4> --description="<detailed description with acceptance criteria>"
```

Set up dependencies between tasks:
```bash
bd dep add <blocked-task> <blocking-task>
```

Confirm creation:
```bash
bd list
```

---

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
   🚀 Started autonomous execution. Monitor progress with:
   - `bd list` - See all tasks
   - `bd ready` - See available work
   - `bd show <id>` - See task details

   I'll report back when complete or blocked.
   ```

---

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

---

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

---
## ⏸️ Awaiting Your Approval

**Proposed tasks:**

| # | Task | Priority | Depends On |
|---|------|----------|------------|
| 1 | Set up JWT dependencies | P0 | - |
| 2 | Create auth middleware | P1 | #1 |
| 3 | Add login/register endpoints | P1 | #1 |
| 4 | Write auth tests | P2 | #2, #3 |
| 5 | Add protected route examples | P2 | #2 |

**Summary:**
- Total tasks: 5
- Ready to start: 1 (no blockers)
- Blocked: 4 (waiting on dependencies)

**Approach:**
First install jsonwebtoken and bcrypt, then create middleware
for JWT verification, add auth endpoints, and finally add tests.

---

**Proceed with this plan?**
- Reply **"yes"** or **"go"** to create tasks and start execution
- Reply with **modifications** to adjust the plan
- Reply **"cancel"** to abort

---

User: yes

Claude: Creating tasks...
[Creates beads issues]

🚀 Started autonomous execution...

[Later]

Completed 5/5 tasks:
  ✓ Set up JWT dependencies
  ✓ Create auth middleware
  ✓ Add login/register endpoints
  ✓ Write auth tests
  ✓ Add protected route examples

All tests passing. Authentication system ready.
```

## Example: Research Task (Escape Hatch)

```
User: ralph: come up to speed with this codebase

Claude:
## 🤔 Task Type Check

This looks like a research/exploration task rather than multi-step implementation work.

**Should I:**
1. **Use full Ralph workflow** - Create beads tasks, show plan, get approval, execute via subagent
2. **Just explore directly** - Search/read files and report back without task overhead

Which approach do you prefer?

User: 2

Claude: [Explores codebase directly and reports findings]
```

## Context Recovery

If context gets compacted mid-session:
1. Run `bd prime` to recover beads context
2. Run `bd list` to see current state
3. Continue from where you left off

## Related

- [beads](https://github.com/steveyegge/beads) - Git-backed issue tracker
- [snarktank/ralph](https://github.com/snarktank/ralph) - External Ralph implementation
