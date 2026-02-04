# Eating Our Own Dog Food: Using Inner Ralph to Improve Inner Ralph

This document captures a real session where we used Inner Loop Ralph to add features to the Inner Loop Ralph plugin itself.

## The Request

```
ralph: add a new feature to inner-ralph
```

## Phase 1: Initialize

Checked beads status - already initialized from previous work:

```
📊 Issue Database Status
Summary:
  Total Issues:           8
  Open:                   0
  Closed:                 8
```

## Phase 2: Analyze & Plan

Analyzed the inner-ralph plugin structure and identified enhancement opportunities:

1. **--dry-run flag** - Preview task breakdown without creating issues
2. **--status flag** - Show progress of running sessions
3. **--cancel flag** - Stop running sessions gracefully
4. **Guardrails template** - Learned constraints to prevent failures

Created beads issues with dependencies:

```bash
bd create --title="Add --dry-run flag to preview task breakdown" --type=feature --priority=0
bd create --title="Add /inner-loop-ralph-status command" --type=feature --priority=1
bd create --title="Add /inner-loop-ralph-cancel command" --type=feature --priority=1
bd create --title="Add guardrails template for learned constraints" --type=feature --priority=2

bd dep add inner-ralph-f73 inner-ralph-vfm  # status depends on dry-run
bd dep add inner-ralph-u9v inner-ralph-vfm  # cancel depends on dry-run
```

## Phase 2.5: Get User Approval

Presented the task breakdown:

| ID | Task | Priority | Blocked By |
|----|------|----------|------------|
| inner-ralph-vfm | Add `--dry-run` flag | P0 | - |
| inner-ralph-f73 | Add `--status` command | P1 | vfm |
| inner-ralph-u9v | Add `--cancel` command | P1 | vfm |
| inner-ralph-ewo | Add guardrails template | P2 | - |

**Summary:** 4 tasks, 2 ready to start, 2 blocked

**User approved:** "Yes, proceed"

## Phase 3: Execute

Worked through tasks in dependency order:

### Task 1: Add --dry-run flag (inner-ralph-vfm)

Updated `SKILL.md` to add:
- New arguments section documenting `--dry-run`, `--status`, `--cancel`
- Phase 0: Parse Arguments with conditional logic for each flag
- Dry-run output format showing proposed tasks without creating them

```bash
bd update inner-ralph-vfm --status=in_progress
# ... made changes to SKILL.md ...
bd close inner-ralph-vfm --reason="Added flags to SKILL.md with Phase 0 argument parsing"
```

### Tasks 2-3: Status and Cancel (inner-ralph-f73, inner-ralph-u9v)

These were implemented as flags in the same SKILL.md update, so they were ready to close immediately after task 1:

```bash
bd close inner-ralph-f73 --reason="Implemented as --status flag in SKILL.md Phase 0"
bd close inner-ralph-u9v --reason="Implemented as --cancel flag in SKILL.md Phase 0"
```

### Task 4: Guardrails template (inner-ralph-ewo)

Created `templates/guardrails-template.md` adapted for beads:
- SIGN-001: Verify Before Closing
- SIGN-002: Check Dependencies Before Starting
- SIGN-003: Use Beads Comments
- SIGN-004: Small Focused Changes
- SIGN-005: Commit After Each Task
- SIGN-006: Don't Skip Blockers
- SIGN-007: Update Status When Starting

Updated SKILL.md Phase 1 to read guardrails file.

```bash
bd update inner-ralph-ewo --status=in_progress
# ... created guardrails template ...
bd close inner-ralph-ewo --reason="Created templates/guardrails-template.md"
```

## Final Status

```
bd list --status=all

✓ inner-ralph-vfm [P0] [feature] - Add --dry-run flag to preview task breakdown
✓ inner-ralph-f73 [P1] [feature] - Add /inner-loop-ralph-status command
✓ inner-ralph-u9v [P1] [feature] - Add /inner-loop-ralph-cancel command
✓ inner-ralph-ewo [P2] [feature] - Add guardrails template for learned constraints
```

**4/4 tasks completed.**

## What We Demonstrated

1. **AI-generated task breakdown** - Claude analyzed the plugin and identified meaningful features
2. **User approval flow** - Presented the plan before executing
3. **Dependency management** - Tasks blocked appropriately until prerequisites complete
4. **Beads persistence** - All task state tracked and visible via `bd list`
5. **Natural workflow** - Claimed tasks, made changes, closed when done

## Key Insight

The same tool we're building is useful for building itself. This "dogfooding" validates that:
- The workflow is practical for real development
- The approval step provides useful oversight
- Beads tracking makes progress visible
- Dependencies prevent out-of-order work
