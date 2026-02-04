# Inner Loop Ralph - Plugin Maintenance Guide

This file provides guidance to Claude Code when working on this plugin repository.

## Plugin Context

This is a Claude Code plugin that provides AI-supervised autonomous agent loops using beads for task tracking.

- **Plugin name**: `inner-loop-ralph`
- **Repository**: https://github.com/dschwartzi/inner-ralph
- **Plugin type**: Skill-based (installed via `/plugin install`)

## Key Differentiators

Unlike external Ralph implementations (snarktank/ralph, ralph-loop-setup):

1. **No external bash loop** - Uses Claude Code's Task tool for subagents
2. **Beads instead of prd.json** - Git-backed issue tracking with dependencies
3. **AI orchestration** - Claude supervises and can intervene intelligently
4. **Context persistence** - Beads survives context compaction

## Version Management

Bump the version in `.claude-plugin/plugin.json` on EVERY meaningful change.

| Change Type | Bump | Example |
|-------------|------|---------|
| Breaking changes | MAJOR | 1.x.x → 2.0.0 |
| New features | MINOR | 1.1.x → 1.2.0 |
| Bug fixes | PATCH | 1.1.0 → 1.1.1 |

## Directory Structure

```
inner-ralph/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── .beads/                   # Beads tracking (for this repo)
├── CLAUDE.md                 # This file
├── LICENSE
├── README.md                 # User-facing docs
└── skills/
    └── inner-loop-ralph/
        ├── SKILL.md          # Main skill definition
        └── templates/        # Optional templates
```

## Testing Changes

1. Install locally: `/plugin install /path/to/inner-ralph`
2. Test with: `ralph: <simple task>`
3. Verify beads issues are created
4. Verify subagent executes tasks
5. Check final state with `bd list`

## Dependencies

- **beads** (`bd` command) must be installed
- Claude Code with Task tool support

## References

- [beads](https://github.com/steveyegge/beads) - Steve Yegge's git-backed issue tracker
- [snarktank/ralph](https://github.com/snarktank/ralph) - Ryan Carson's external Ralph
- [ralph-loop-setup](https://github.com/MarioGiancini/ralph-loop-setup) - Mario Giancini's skill
