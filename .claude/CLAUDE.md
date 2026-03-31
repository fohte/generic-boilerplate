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
