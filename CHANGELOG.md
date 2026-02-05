# Changelog

All notable changes to inner-loop-ralph will be documented in this file.

## [1.2.0] - 2026-02-05

### Changed
- **BREAKING**: Removed `--dry-run` flag - plan preview is now always shown before task creation
- Added mandatory approval gate (Phase 2.5) with strict format requirements
- Added Task Type Check escape hatch for research/exploration tasks
- Split task creation into Phase 2.6 (only runs after approval)
- Strengthened constraint language with "VIOLATION IS FAILURE" block

### Added
- Visual markers in approval prompt (emojis, horizontal rules)
- Escape hatch asks user to choose between full workflow or direct exploration
- Example session showing escape hatch flow in SKILL.md

### Fixed
- Prevents model from bypassing approval gate by using Task tool directly

## [1.1.0] - 2026-02-04

### Added
- `--dry-run` flag to preview task breakdown without creating beads issues
- `--status` flag to show progress of current/recent sessions
- `--cancel` flag to stop running sessions gracefully
- Guardrails template (`templates/guardrails-template.md`) with beads-specific signs
- Phase 0: Parse Arguments in SKILL.md for flag handling
- Real-world "dogfooding" example (`examples/dogfooding-session.md`)

### Changed
- SKILL.md now reads guardrails file in Phase 1 if present
- Subagent prompts include guardrails to prevent repeated failures

### Meta
- This release was built using Inner Loop Ralph itself (see dogfooding example)

## [1.0.0] - 2026-02-04

### Added
- Initial release of inner-loop-ralph skill
- SKILL.md with full instruction set for AI-supervised autonomous loops
- Beads integration for persistent task tracking
- Task tool subagent execution
- Support for task dependencies via `bd dep add`
- Context recovery via `bd prime`
- Templates for CLAUDE.md protocol setup

### Features
- `ralph:` protocol prefix support (via CLAUDE.md addition)
- `/inner-loop-ralph <description>` direct invocation
- Automatic project analysis and task breakdown
- Subagent monitoring with natural conversation intervention
- Git-backed state persistence

### Tested
- End-to-end workflow with dependent tasks
- Subagent task completion loop
- Beads commands (ready, update, close, list)
