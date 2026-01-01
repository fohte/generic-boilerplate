# Generic Boilerplate

A [Copier](https://copier.readthedocs.io/) template for common development configurations.

## What's Included

- `.editorconfig` - Editor configuration
- `.mise.toml` - Tool version management ([mise](https://mise.jdx.dev/))
- `lefthook.yml` - Git hooks ([lefthook](https://github.com/evilmartians/lefthook))
  - `commitlint.config.js` - Commit message linting ([commitlint](https://commitlint.js.org/))
  - `.prettierrc.yaml` - Code formatting ([Prettier](https://prettier.io/))
- `.github/workflows/test.yml` - CI workflow
- `renovate.json5` - Dependency updates ([Renovate](https://docs.renovatebot.com/))

## Prerequisites

Configure a GitHub App for CI workflows:

1. Create a GitHub App with the following repository permissions:
   - Contents: Read and write
   - Pull requests: Read and write
2. Install the App to your repository
3. Add the following Repository secrets:
   - `APP_ID`: GitHub App's App ID
   - `APP_PRIVATE_KEY`: GitHub App's Private Key

## Usage

### Create a new project

```bash
copier copy https://github.com/fohte/generic-boilerplate <destination>
```

### Update an existing project

Projects created from this template can receive updates via [Copier](https://copier.readthedocs.io/).

```bash
copier update
```

[Renovate](https://docs.renovatebot.com/modules/manager/copier/) automatically creates PRs when the template is updated (if `copier.enabled` is set in `renovate.json5`).

## Versioning

This repository uses [Semantic Versioning](https://semver.org/) (via [release-please](https://github.com/googleapis/release-please)) because Renovate's [Copier manager](https://docs.renovatebot.com/modules/manager/copier/) requires [PEP 440](https://peps.python.org/pep-0440/)-compliant version tags (e.g., `0.1.0`) to detect template updates.

## Parameters

| Parameter            | Type | Default | Description                                                                                                                  |
| -------------------- | ---- | ------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `description`        | str  | `''`    | Project description for README.md.                                                                                           |
| `is_public`          | bool | `false` | Set to `true` for public repositories. Enables commitlint rule to prevent external GitHub references in commit messages.     |
| `use_release_please` | bool | `true`  | Enable automated release management with release-please.                                                                     |
| `release_type`       | str  | -       | Select the release-type for your project (simple, node, python, go, rust, java). Required when `use_release_please` is true. |

## Dependency Version Strategy

This template uses **pinned versions** (e.g., `"eslint": "8.57.1"`) instead of version ranges (e.g., `"eslint": "^8.0.0"`) for all dependencies.

### Why pinned versions?

When generated projects have Renovate enabled, using version ranges causes conflicts:

1. Renovate updates dependencies in the generated project
2. User merges the Renovate PR
3. Later, `copier update` tries to apply template changes
4. Conflict occurs because the template still has the old version

### How it works

1. Renovate updates dependencies in `generated/` directory
2. `sync-generated-to-template` workflow patches the template with new versions
3. Users running `copier update` receive the same versions Renovate would provide
4. Their local Renovate sees no update needed (or minimal diff)

This keeps the template in sync with Renovate's understanding of "latest", reducing conflicts significantly.

## Template Development

The following files are used by Copier and are not part of the generated project:

- `copier.yml` - Copier configuration
- `.copier-answers.yaml.jinja` - Template for storing answers in downstream projects
- `README.md.jinja` - Template for the README in downstream projects
- `README.md` - This file (documentation for the template itself)
