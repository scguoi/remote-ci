# Repository Guidelines

## Project Structure & Modules
- Root Makefile orchestrates a multi-language toolchain; language modules live in `makefiles/`.
- Services:
  - `backend-go/` (Go), `backend-java/` (Maven multi-module: `user-*`), `backend-python/`, `frontend-ts/` (Vite + TS).
- Tests (where present):
  - TypeScript: `frontend-ts/src/__tests__/` (Jest).
  - Java: `backend-java/*/src/test/java/` (Maven Surefire).
  - Go: add `*_test.go` beside packages.
  - Python: place tests under `backend-python/tests/` (unittest) if added.

## Build, Test, and Dev Commands
- Discover commands: `make help` and `make project-status`.
- One-time setup: `make dev-setup` (installs tools, Git hooks, branch helpers).
- Format: `make fmt` | Check format: `make fmt-check`.
- Lint/quality: `make check` | Tool sanity: `make check-tools`.
- Language examples:
  - Go: `make fmt-go`, `make check-go`.
  - TypeScript: `make fmt-typescript`, `make check-typescript`, run app `cd frontend-ts && npm run dev`, tests `npm test`.
  - Java: `make fmt-java`, `make check-java`, build `make build-java`, run `make run-java`, tests `make test-java`.
  - Python: `make fmt-python`, `make check-python`.

## Coding Style & Naming
- Go: gofmt/goimports + gofumpt; wrap with `golines` (120 cols).
- TypeScript: Prettier + ESLint (`frontend-ts/eslint.config.js`).
- Java: Spotless (Google Java Format), Checkstyle, SpotBugs.
- Python: Black + isort; Flake8, MyPy, Pylint (fail-under 8.0).
- Branches (GitHub Flow): `feature/…`, `bugfix/…`, `hotfix/…`, `design/…`, `doc/…`, `refactor/…`, `test/…`.
- Commits: Conventional Commits, e.g. `feat(auth): add login api`.

## Testing Guidelines
- Keep tests close to code; follow directory patterns above.
- Aim for fast, deterministic unit tests; prefer defaults (Jest for TS, Maven Surefire for Java, `go test ./...` for Go).
- Name tests clearly; mirror source paths.

## Commit & Pull Requests
- Before committing: `make fmt` and `make check` (or install hooks: `make hooks-install`).
- PRs should include: clear description, linked issues, how-to-test steps, and screenshots for UI changes.
- Keep PRs small and focused; update relevant docs when behavior changes.

## Environment Notes
- TypeScript requires Node 18+. Java requires JDK 17+. Go 1.24+. Python 3.9+.
- Python toolchain uses a specific interpreter path in `makefiles/python.mk` (`PYTHON := /Users/scguo/.virtualenvs/mydemos/bin/python`). Adjust to your venv or update that variable locally.
