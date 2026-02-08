# Repo Working Agreements

## Git workflow
- Commit after every code change.
- Push to `origin main` after every 20 local commits, or when explicitly asked.

## Communication
- The user is not a native English speaker. For every user message (including Chinese), first provide a clear English rephrase from the user's perspective in first person, then provide the final answer in Traditional Chinese. Do not start the rephrase with boilerplate openers such as "I want to know," "I would like to," or "I want."
- When replying, assume the agent and user are on the same team; use "we/our" phrasing where appropriate.
- When the user asks for a solution or recommendation, provide multiple viable options by default, not just a single "best" answer.
- For each option, include a one-line tradeoff (cost/time/risk/complexity) so the user can choose.
- If the right choice depends on unknown constraints, ask 1-2 short clarifying questions, but still provide a best-effort set of options based on common assumptions.
- If the user request involves bypassing security controls or policy, refuse that part and provide compliant alternatives (still offer multiple options).
- If you use an uncommon English term, include a brief Traditional Chinese translation the first time you use it (for example: "orchestrator (流程編排器)").

## AssetLib
- For any new feature request, first search the Godot Asset Library (AssetLib) for existing add-ons/templates we can reuse.
- If there are candidates, present options with license + Godot version compatibility + integration effort, and prefer reuse when it reduces time/risk.
- If we adopt an asset, add it to `assets/CREDITS.md` with source + license details.

## New chat bootstrap
- Run `git status -sb` to understand the repo state.
- Scan the repo layout with `ls` and prefer `rg --files` for fast file discovery.
- Reply with a short plan and the current repo status before making changes.

## Command output / logs
- When running shell commands, avoid prefixing with `cd ...;` in the command text. Use the tool `workdir` instead so the log shows the important command (e.g. `git status -sb`).
- When showing commands in messages, display only the key command and omit setup noise where possible.
- When running git commands, prefer the repo-local shim `tools/git.cmd` so logs don't show an absolute path to git.exe.
- When referencing tool executions in messages, do not paste wrapper prefixes like `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command ...`; show only the core command (e.g. `tools/git.cmd push origin main`).

## README.md
- Read README.md from the root of every folder, if it exists.
