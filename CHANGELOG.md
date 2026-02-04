# Changelog

All notable changes to inner-loop-ralph will be documented in this file.

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
