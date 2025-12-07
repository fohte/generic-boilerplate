# Generic Boilerplate

A [Copier](https://copier.readthedocs.io/) template for common development configurations.

## What's Included

- `.editorconfig` - Editor configuration
- `.pre-commit-config.yaml` - Pre-commit hooks
- `.github/workflows/test.yml` - CI workflow
- `renovate.json5` - Renovate configuration

## Usage

### Create a new project

```bash
copier copy gh:fohte/generic-boilerplate <destination>
```

### Update an existing project

```bash
copier update
```

Renovate can automatically create PRs when the template is updated.
