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
copier copy https://github.com/fohte/generic-boilerplate <destination>
```

### Update an existing project

```bash
copier update
```

Renovate can automatically create PRs when the template is updated.

## Parameters

| Parameter   | Type | Default | Description                                                                                                              |
| ----------- | ---- | ------- | ------------------------------------------------------------------------------------------------------------------------ |
| `is_public` | bool | `false` | Set to `true` for public repositories. Enables commitlint rule to prevent external GitHub references in commit messages. |

## Template Development

The following files are used by Copier and are not part of the generated project:

- `copier.yml` - Copier configuration
- `.copier-answers.yaml.jinja` - Template for storing answers in downstream projects
- `README.md.jinja` - Template for the README in downstream projects
- `README.md` - This file (documentation for the template itself)
