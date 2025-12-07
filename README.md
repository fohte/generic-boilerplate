# Generic Boilerplate

A [Copier](https://copier.readthedocs.io/) template for common development configurations.

## Overview

This repository provides a reusable template for setting up common development configurations. Terraform directly runs `copier copy` to create new repositories from this template.

### How it works

1. **New repository creation**: Terraform creates a repository and runs `copier copy` to initialize it
2. **Update propagation**: Renovate periodically checks for template updates and creates PRs via `copier update`

## What's Included

- `.editorconfig` - Editor configuration
- `.pre-commit-config.yaml` - Pre-commit hooks
- `.github/workflows/test.yml` - CI workflow
- `renovate.json5` - Renovate configuration

## Template-only files

The following files exist only in this template repository and are removed/replaced in downstream repositories:

- `copier.yml` - Copier configuration
- `.copier-answers.yaml.jinja` - Copier answers template
- `README.md` - Replaced by `README.md.jinja`
