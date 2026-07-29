#!/bin/bash
# PostToolUse hook on ExitPlanMode: fires every time a plan is approved.
# Injects a mandatory post-planning workflow into Claude's context.
#
# NOTE: this hook deliberately does NOT decide where the plan is stored.
# The "Planning & execution" section of ~/.claude/CLAUDE.md is the single
# source of truth for that (Artifact first, .claude/plans/*.md as fallback).
# Keep this hook medium-agnostic so the two can't drift apart again.
read -r -d '' context <<'EOF'
MANDATORY POST-PLANNING WORKFLOW (hook-enforced): the plan was just approved. Before writing ANY implementation code you MUST: (1) Record the approved plan following the "Planning & execution" rules in ~/.claude/CLAUDE.md — publish it as an Artifact, falling back to .claude/plans/PLAN-<short-task-slug>.md under the project root only when Artifacts are unavailable. Do not write a plan markdown file when an Artifact was published. (2) Whichever medium is used, the plan must contain the goal, the approach, and a markdown todo checklist ('- [ ]' items) of concrete implementation steps, and must be self-contained so other agents can act on it alone. (3) Create a matching todo list with the TodoWrite tool. (4) While implementing, keep both in sync: check off items as they complete, and revise the plan whenever the approach changes — republish to the same Artifact URL rather than creating a new one. (5) When the task is fully done, mark all todos complete, and delete the temporary plan file if the markdown fallback was used.
EOF
jq -n --arg ctx "$context" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
