# Global instructions

## Planning & execution

- After planning any non-trivial task, publish the implementation plan as an Artifact instead of writing a markdown file. The Artifact should contain:
  - A short summary of the goal and approach
  - A todo list / checklist of concrete implementation steps
- To update the plan, edit the same source file and republish to the same Artifact URL so the link stays stable — don't mint a new Artifact for each revision.
- Treat the plan as a living document: check off items in the Artifact as they're completed, and revise/improve the plan when new information or obstacles appear during implementation.
- If a task references an existing plan Artifact, read it first (via its URL) and follow its approach instead of re-planning from scratch.
- Fallback: if Artifacts are unavailable (e.g. offline or no publish access), write the plan to `.claude/plans/PLAN-<short-task-slug>.md` under the project root instead, and delete it once the task is fully complete.

## Code quality

- Prefer the simplest solution that works; avoid speculative abstractions (YAGNI).
- Match the existing code style, naming, and idioms of each project — don't impose personal preferences.
- Prefer editing existing files over creating new ones; avoid drive-by refactors outside the task's scope.
- Reuse existing dependencies and stdlib before adding new packages; check which package manager the project uses first.

## Verification

- Never claim a change works without verifying — run the relevant tests, linter, and type checker after edits.
- When fixing a bug, first reproduce it, then fix, then confirm the reproduction now passes.

## Git & safety

- Never commit, push, or open PRs unless explicitly asked.
- Ask before destructive or hard-to-reverse actions: force push, rebase, deleting files/branches, DB migrations, dropping data.
- Never hardcode secrets or API keys; use env vars, and never echo `.env` contents into output or commits.

## Communication

- Lead with the outcome/answer, then supporting detail.
- When multiple valid approaches exist, pick one, state it, and briefly note the tradeoff — don't present option menus for routine decisions.
- Report failures honestly: if tests fail or a step was skipped, say so plainly.
