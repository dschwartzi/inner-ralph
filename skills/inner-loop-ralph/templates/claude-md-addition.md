# Ralph Protocol (Inner Loop)

Add this to your `~/.claude/CLAUDE.md` to enable the `ralph:` prefix:

```markdown
## Ralph Protocol (Autonomous Mode)

When the user says `ralph: [description]` or `ralph [description]`:

1. Invoke the inner-loop-ralph skill: `/inner-loop-ralph [description]`

This will:
- Analyze the codebase
- Create beads issues with dependencies
- Spawn a subagent to work through tasks
- Report back when complete or blocked
```

## Alternative: Direct Invocation

You can also invoke directly without the protocol:

```
/inner-loop-ralph implement user authentication with OAuth
```
