# Tmux Session-Scoped Environment Config — Design

Date: 2026-06-30

## Goal

Set environment variables per **tmux session name**. When a shell starts inside a
tmux session named `bunjang`, `pp`, or `hs`, automatically load environment
variables specific to that session. Files are scaffolds for now — the actual
`export`s will be filled in later by the user.

## Approach

Reuse the existing auto-source mechanism: `.zshrc` already runs
`for f in '$REPO/profiles'/*; do source $f; done` (injected by `init.sh`). Add one
dispatcher file to `profiles/` that detects the tmux session name and sources the
matching per-session file.

Per-session files live in `configs/tmux-sessions/` — **not** under `profiles/`,
because every file in `profiles/` is sourced into every shell, which would defeat
the per-session scoping. The directory name is `tmux-sessions` (not a generic
`sessions`) to make explicit that the key is the tmux session name.

## Components

### 1. `configs/tmux-sessions/{bunjang,pp,hs}.sh` — scaffolds
Each file: a header comment naming the session and a commented-out `export`
example showing where the user adds real variables. No active exports yet.

### 2. `profiles/tmux-session-env.sh` — dispatcher
Auto-sourced by the existing `profiles/*` loop. Logic (zsh-only — uses `${(%):-%x}`):

```zsh
# Resolve this repo's root from the dispatcher's own location,
# independent of init.sh-time variables.
_repo_root="${${(%):-%x}:A:h:h}"     # zsh: script path -> abs -> profiles/ -> repo root

[ -n "$TMUX" ] || return             # not inside tmux -> no-op
_sess="$(tmux display-message -p '#S' 2>/dev/null)"
[ -n "$_sess" ] || return

_sess_file="$_repo_root/configs/tmux-sessions/$_sess.sh"
[ -r "$_sess_file" ] && source "$_sess_file"

unset _repo_root _sess _sess_file
```

Notes:
- Uses zsh's `${(%):-%x}` to get the sourced script's own path, so the dispatcher
  has no dependency on `init.sh`'s `$CURRENT_DIR` (which only exists at install
  time, not shell-runtime). `.zshrc`/profiles run under zsh, matching the repo.
- Silent no-op when: not in tmux, session name empty, or no matching file.
- Temp vars are unset to avoid leaking into the session environment.

## Data Flow

open/attach a tmux pane → new zsh → `profiles/*` sourced →
`tmux-session-env.sh` reads `#S` → sources `configs/tmux-sessions/<name>.sh`
→ env vars set for that pane.

## Out of Scope / Known Limitations

- Env vars are set at **shell startup**. Renaming a session does not retroactively
  update already-open panes; a new pane picks up the new name. This matches the
  existing profile model.
- No change to `init.sh` needed — the dispatcher is just another `profiles/` file.

## Testing

- `zsh -n` syntax check on the dispatcher and scaffolds (the dispatcher is zsh-only; `bash -n` would error on `${(%):-%x}`).
- Manual: run dispatcher logic with `TMUX` unset (no-op) and with a faked session
  name resolving to an existing scaffold (sources it), confirming no errors and no
  leaked temp vars.
