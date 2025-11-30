# Generic Boilerplate

A template for common development configurations. This repository serves as both a **GitHub Template Repository** and a **[Copier](https://copier.readthedocs.io/) template**.

## Overview

GitHub Template Repositories only copy files at repository creation time and cannot propagate updates to downstream repositories. This repository combines GitHub Templates with Copier to enable automatic update propagation.

### How it works

1. **New repository creation**: Terraform creates a repository using this as a GitHub Template
2. **Automatic Copier initialization**: The `init-copier.yml` workflow runs and executes `copier copy`
3. **Update propagation**: Renovate periodically checks for template updates and creates PRs via `copier update`

## What's Included

- `.editorconfig` - Editor configuration
- `.pre-commit-config.yaml` - Pre-commit hooks
- `.github/workflows/test.yml` - CI workflow
- `renovate.json5` - Renovate configuration

## Template-only files

The following files exist only in this template repository and are removed/replaced in downstream repositories:

- `copier.yml` - Copier configuration
- `.copier-answers.yaml.jinja` - Copier answers template
- `.github/workflows/init-copier.yml` - One-time initialization workflow
- `README.md` - Replaced by `README.md.jinja`
