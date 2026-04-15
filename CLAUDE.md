# generic-boilerplate

Copier template repository for generating GitHub Actions workflows and project scaffolding.

## Architecture

- `template/`: Copier template directory. Files here are rendered into derived repositories via `copier copy`
- `generated/`: Snapshot fixtures for each test fixture configuration. Used by CI to validate template rendering
- `copier.yml`: Template parameter definitions and exclusion rules

## Template symlink convention

When a file in `template/` has identical content to a file in the repository root, it MUST be a symlink pointing to the root file (e.g., `template/.editorconfig -> ../.editorconfig`). This avoids content duplication and ensures changes to the root file are automatically reflected in the template.

- Root file: the real file (e.g., `.github/workflows/pr-title-check.yml`)
- Template file: a symlink to the root (e.g., `template/.github/workflows/pr-title-check.yml -> ../../../.github/workflows/pr-title-check.yml`)
- Never copy files between root and template; always use symlinks

## Snapshot generation

- `generated/` directory contains snapshot fixtures auto-generated from `template/` and `tests/fixtures/*.yml`
- Never edit files in `generated/` directly. Always modify the template source and regenerate
- Run `scripts/generate-snapshots` to regenerate all snapshots after template changes
- `scripts/generate-snapshots` intentionally omits `--defaults`. If a fixture is missing any parameter, copier drops into an interactive prompt and fails in non-TTY contexts. This fail-loud behavior enforces the rule that every fixture explicitly specifies every parameter

## CI validation

`.github/workflows/validate-template.yml` validates template changes through the following jobs. New template files must be designed to pass all of them:

- `regenerate-and-commit`: runs `scripts/generate-snapshots` and auto-commits any diff in `generated/`. If you forget to regenerate locally, CI will commit the regeneration for you, but any push that also touches `generated/` inconsistently will still need to reconcile
- `validate (<fixture>)`: for each fixture in `tests/fixtures/`, initializes a git repo inside `generated/<fixture>/`, runs `lefthook run pre-commit --all-files` (prettier, eslint, etc. as configured by that fixture's own lefthook), then fails if any file has a diff. **This means every file under `generated/` must already be in the exact form its own lefthook would produce.**
- `validate-node` / `validate-rust`: run the generated project's test suite when the corresponding `generated/node` or `generated/rust` tree changed

### Implications for `template/` authors

- Because generated files must be lefthook-clean, the bytes emitted by copier rendering must already match the downstream formatter's output. Prettier cannot format `.jinja` files directly (it errors on unknown parser), so you cannot rely on post-rendering formatting of the jinja source itself
- Write jinja templates so that the rendered output is byte-identical to what prettier (or the relevant formatter) would produce. For constructs where an inline conditional would break formatter invariants (e.g. a markdown table cell whose width changes between branches of a `{% if %}`), split the whole block with `{% if %}` / `{% else %}` instead of using an inline ternary, so each branch is independently well-formatted
- Any new parameter added to `copier.yml` must be set in every `tests/fixtures/*.yml`; otherwise `scripts/generate-snapshots` will hang on a prompt in CI (see above)

## Test fixture policy

- Do not add new fixtures for every feature combination. Each fixture increases CI cost and maintenance burden due to combinatorial explosion
- When adding a new template feature, enable it in an existing fixture rather than creating a dedicated fixture
- Only add a new fixture when the feature requires a fundamentally different project structure that no existing fixture covers (e.g., a new `type` value)
- Rare or unlikely configurations do not need fixture coverage
