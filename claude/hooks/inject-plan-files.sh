#!/bin/bash
# UserPromptSubmit hook: if the current project has plan files in .claude/plans/,
# inject their listing into context so the agent checks them before implementing.
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$cwd" ] && cwd="$PWD"
plans_dir="$cwd/.claude/plans"
[ -d "$plans_dir" ] || exit 0
files=$(find "$plans_dir" -maxdepth 2 -type f -name '*.md' -printf '%P\n' 2>/dev/null | sort)
[ -z "$files" ] && exit 0
jq -n --arg files "$files" --arg dir "$plans_dir" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: ("PLAN FILES PRESENT (hook-injected): this project has implementation plan files in \($dir): " + ($files | split("\n") | join(", ")) + ". Before implementing any related task, read the relevant plan file first, follow its approach, and keep its todo checklist updated as you work.")
  }
}'
