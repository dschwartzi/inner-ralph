# Inner Ralph Guardrails (Signs)

Learned constraints that prevent repeated failures. Each "sign" is a rule discovered through iteration failures. Add new signs as you encounter failure patterns.

> "Progress should persist. Failures should evaporate." - The Ralph philosophy

---

## Verification Signs

### SIGN-001: Verify Before Closing
**Trigger:** About to run `bd close` on a task
**Instruction:** ALWAYS run the verification command (tests, lint, type check) and confirm it passes before closing the task
**Reason:** Closing a task should mean it's done and verified, not just "code written"

### SIGN-002: Check Dependencies Before Starting
**Trigger:** Picking a task from `bd ready`
**Instruction:** Run `bd show <id>` to see full description and acceptance criteria. Ensure you understand what "done" means before starting.
**Reason:** Prevents partially completing tasks or missing acceptance criteria

---

## Progress Signs

### SIGN-003: Use Beads Comments
**Trigger:** Discovering important context while working
**Instruction:** Add comments to beads issues with `bd comments add <id> "context..."` to preserve learnings
**Reason:** Future sessions can recover context via `bd show` even after conversation compaction

### SIGN-004: Small Focused Changes
**Trigger:** Working on any task
**Instruction:** Keep changes small and focused. One task = one logical unit of work. If scope grows, create a new beads issue for the additional work.
**Reason:** Large changes are harder to debug when verification fails

### SIGN-005: Commit After Each Task
**Trigger:** Completing a task
**Instruction:** Commit your changes BEFORE running `bd close`. Include task ID in commit message: `feat(inner-ralph-abc): description`
**Reason:** Ensures progress is saved even if something goes wrong after

---

## Task Management Signs

### SIGN-006: Don't Skip Blockers
**Trigger:** Task is blocked by another task
**Instruction:** Never start a blocked task. Always check `bd ready` to find unblocked work. If all tasks are blocked, report the blocker.
**Reason:** Working on blocked tasks creates incomplete or conflicting work

### SIGN-007: Update Status When Starting
**Trigger:** Beginning work on a task
**Instruction:** ALWAYS run `bd update <id> --status=in_progress` before starting work
**Reason:** Prevents multiple agents from claiming the same task; shows progress in `bd list`

---

## Project-Specific Signs

Add signs below as you encounter project-specific failure patterns:

<!-- Example format:
### SIGN-XXX: [Descriptive Name]
**Trigger:** [When this sign applies]
**Instruction:** [What to do instead]
**Reason:** [Why this matters]
**Added after:** [Which task / when learned]
-->
