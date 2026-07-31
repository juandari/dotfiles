# Global instructions

## Planning & execution

- After planning any non-trivial task, write the implementation plan to a **local markdown file** at `.claude/plans/PLAN-<short-task-slug>.md` under the project root (not a claude.ai Artifact — a local file so any agent can read and edit it with zero friction). The file should contain:
  - A short summary of the goal and approach
  - A todo list / checklist of concrete implementation steps (`- [ ]` / `- [x]`)
- The markdown file is the single source of truth. Treat it as a living document: check off items as they're completed, and revise/improve the plan when new information or obstacles appear during implementation. Edit the same file in place — don't create a new file per revision.
- If a task references an existing plan file, read it first and follow its approach instead of re-planning from scratch.
- Human view (optional): plans render at `http://localhost:3030` via a zero-dependency viewer that live-reloads on file change. Start it from the project root with:
  `node ~/dotfiles/claude/tools/plan-viewer.mjs` (defaults to `./.claude/plans` on port 3030; override with a dir arg and `--port N`). Agents never talk to the server — they only edit the `.md` files; the server is a read-only rendered view.
- Delete a plan file once its task is fully complete and has been code-reviewed, not right after implementation finishes.

## Shell

- The user's shell is fish. When setting env vars or writing any shell commands (Bash tool or otherwise), use fish syntax (e.g. `set -x KEY value`, not `export KEY=value`), not bash/zsh syntax.

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
