---
name: wizard
description: Generates an interactive bash wizard that walks a human through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover.
compatibility: Requires bash. The generated wizard opens URLs with wslview, explorer.exe, xdg-open, or open, and writes GitHub secrets and variables with gh when it is installed and authenticated; shellcheck is optional.
license: MIT
metadata:
  author: "Sascha Grau"
  version: "1.1.0"
  category: "engineering"
---

# Wizard

A **wizard** is a bash script that walks a human, stage by stage, through a manual procedure: it opens each URL, says exactly what to click and copy, captures the values, writes them where they belong (`.env`, GitHub secrets), confirms at every stage, and shows how many stages are left.

[template.sh](assets/template.sh) already carries the UX: the library above the `STAGES` marker is identical in every wizard, and each helper is documented where it is defined. Your job is only to scope the procedure and author its stages below the marker.

## Process

### 1. Scope the procedure

Work out every manual step the human must take and every value captured along the way. Read the repo before asking the user anything:

- For setup: `.env`, `.env.example`, `.env.*`, `README`, `docker-compose*`, framework config, and `.github/workflows/*` (every `secrets.*` / `vars.*` reference is a value the wizard must produce, except platform-provided ones such as `GITHUB_TOKEN`).
- For a migration or transition: the current state, the target state, and the irreversible actions between them.

Cut the stages so each one runs start to finish at one URL at most, with no pause in the middle: a task that crosses consoles, or mixes reversible with one-way actions, becomes separate stages, and each one-way action gets a stage of its own.

Then show the user the **stage list**: the stages in order and, per captured value, where the human gets it, where it's written (`.env`, a GitHub secret or variable, both, or nowhere; some stages are pure actions), and whether it's secret (hidden entry) or public, as a table:

| Stage | Value or action | Source | Destination and key | Secret/public/— |
| --- | --- | --- | --- | --- |
| 1. CI app | FLY_APP_NAME | Fly app page | GitHub variable FLY_APP_NAME | Public |

End your turn after the table and wait for the user's reply; they may add, drop, or reorder. Write nothing under `scripts/` before that reply, unattended run or not.

**Complete when:** the user has replied confirming the stage list.

### 2. Map each stage's journey

For each stage, write the precise path a human follows: which URL to open, what to do there, where a value is shown, which variable it fills, e.g. "Dashboard → Developers → API keys → Reveal test key → copy". Where you don't know the current UI or the exact command, load the `research` skill (the Skill tool on Claude Code) and let it check the vendor docs; your own direct fetch of a docs page does not count. Where the docs don't settle it, ask the user.

**Complete when:** every stage traces to instructions a stranger could follow, each backed by the vendor docs or the user's confirmation.

### 3. Author the wizard

Copy `assets/template.sh` to `scripts/<name>.sh` in the repo. Set the `banner` title, replace the example stage with one `stage` per entry in the stage list, in dependency order, and set `TOTAL_STAGES` to the number of stages you wrote.

Hold the bar the template sets: open the URL before asking for its value, use `ask_secret` for anything secret, write each value exactly where the stage list says (`write_env` for `.env`, `set_secret` for what CI reads as `secrets.*`, `set_var` for what it reads as `vars.*`), and `confirm` before any irreversible action, whether the script runs it or the human is told to click it: `confirm "<action>?" || { warn "Stopped before <action>"; exit 1; }`. Each `stage` clears the screen so only the current stage is visible: end every stage with `pause`, so nothing the human needs scrolls away before they have read it.

**Complete when:** `TOTAL_STAGES` equals the stages written, every captured value in the stage list has its ask and exactly the write calls its destination says, every stage opens at most one URL and ends with its only `pause`, and every irreversible action sits in a stage of its own with its own `confirm`.

### 4. Verify and hand off

- `bash -n <script>`; run `shellcheck` if available.
- `diff <(sed '/^# STAGES/q' <skill-dir>/assets/template.sh) <(sed '/^# STAGES/q' <script>)` prints nothing: the library is byte-identical to the template.
- `chmod +x <script>`.
- Trace it statically rather than running it end-to-end, since it opens browsers and blocks on human input: every value in the stage list is captured and lands where the stage list says, and every `set_secret` / `set_var` name exactly matches a `secrets.*` / `vars.*` reference in CI.
- Tell the user to run it from the repo root (`ENV_FILE` defaults to `./.env`) and that the wizard is theirs to delete once the job is done. When they want a repeatable setup path instead, commit it and link it from the README.

**Complete when:** the syntax check passes (and `shellcheck`, where available), the library diff is empty, the script is executable, the static trace matches the stage list, and the user knows the command to run it.
