# Generic Boilerplate

A [Copier](https://copier.readthedocs.io/) template for common development configurations.

## Usage

### Create a new repository

```bash
copier copy gh:fohte/generic-boilerplate <destination>
```

### Update an existing repository

```bash
copier update
```

## What's Included

- `.editorconfig` - Editor configuration
- `.pre-commit-config.yaml` - Pre-commit hooks
- `.github/workflows/test.yml` - CI workflow
- `renovate.json5` - Renovate configuration

## Repository Structure

This repository uses a `template/` subdirectory for Copier template files. This allows the repository itself to be managed by Copier.

```
├── template/           # Copier template source
│   ├── .editorconfig
│   ├── .pre-commit-config.yaml
│   ├── .github/workflows/test.yml
│   ├── renovate.json5
│   ├── .copier-answers.yaml.jinja
│   └── README.md.jinja
├── copier.yml          # Copier configuration
├── .copier-answers.yaml  # This repo is also managed by Copier
└── README.md           # This file (not from template)
```
