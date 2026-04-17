# Docker Compose Shareability (Option A)

**Date:** 2026-04-17
**Scope:** Minimal changes to make `docker-compose.yml` safe to share via a public repo while preserving the current single-user workflow and existing persisted data.

## Problem

The existing `docker-compose.yml` bakes in assumptions that worked for solo use but break when the repo is public:

1. **Git identity hard-coded** — `GIT_AUTHOR_NAME=William` / `ochowei@gmail.com` leak into the repo; anyone who clones and runs without editing the file will commit under the original author's name.
2. **`external: true` volumes** — A first-time user must pre-run `docker volume create claude-gh-config` (and two others) or `docker compose up` fails outright. Unfriendly onboarding.
3. **`container_name` pinned** — Prevents running two workspaces in parallel (e.g. two different repos).

## Goals

- New user can `git clone` → `cp .env.example .env` → edit → `docker compose run --rm workspace` and it just works.
- Current user's persisted state (gh auth, Claude Code config, zsh history) must survive the change — no data migration.
- `.env` with personal data never enters git.

## Non-Goals

- SSH key mounting, UID alignment, timezone, restart policy, multi-profile setup — deferred to a later iteration. Solo user doesn't need them today.

## Design

### 1. `.env.example` (new, committed)

```env
GIT_AUTHOR_NAME=Your Name
GIT_AUTHOR_EMAIL=you@example.com
GIT_COMMITTER_NAME=Your Name
GIT_COMMITTER_EMAIL=you@example.com
```

### 2. `.gitignore` (new or updated)

Add `.env` so personal config stays local.

### 3. `docker-compose.yml` changes

- **Environment block**: reference variables instead of literals (`${GIT_AUTHOR_NAME}` etc.). Compose auto-loads `.env` from the compose file's directory.
- **Remove `container_name`**: let compose generate per-project names so two instances don't collide.
- **Volumes**: replace `external: true` with `name: <volume-name>`. This preserves the exact volume name (so existing `claude-gh-config` etc. are reused — no data loss) while letting compose auto-create the volume on first run if it doesn't exist.

### 4. `README.md` update

- First-time flow becomes: `cp .env.example .env` → edit → `docker compose run --rm workspace`.
- Remove the `docker volume create` bootstrap step (no longer needed).

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Existing volumes orphaned after rename | `name:` keeps exact names — volumes are reused as-is. |
| `.env` missing on someone's machine | Compose still runs; only git identity env vars are empty. Acceptable — commits will fail or be anonymous, but container works. |
| Committed `.env` accidentally | `.gitignore` entry prevents it. Review diffs when committing. |

## Validation

- `docker compose config` parses cleanly.
- `docker compose run --rm workspace env | grep GIT_` shows values from local `.env`.
- `docker volume ls` still shows `claude-gh-config`, `claude-code-config`, `claude-zsh-history` (not prefixed with project name).
- `gh auth status` inside the container still reports logged in (confirms volume reuse).
