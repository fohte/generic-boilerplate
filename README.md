# Generic Boilerplate

A [Copier](https://copier.readthedocs.io/) template for common development configurations.

## What's Included

- `.editorconfig` - Editor configuration
- `.mise.toml` - Tool version management ([mise](https://mise.jdx.dev/))
- `lefthook.yml` - Git hooks ([lefthook](https://github.com/evilmartians/lefthook))
  - `commitlint.config.js` - Commit message linting ([commitlint](https://commitlint.js.org/))
  - `.prettierrc.yaml` - Code formatting ([Prettier](https://prettier.io/))
- `.github/workflows/test.yml` - CI workflow ([GitHub Actions](https://docs.github.com/en/actions))
- `renovate.json5` - Dependency updates ([Renovate](https://docs.renovatebot.com/))

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

| Parameter     | Type | Default | Description                                                                                                              |
| ------------- | ---- | ------- | ------------------------------------------------------------------------------------------------------------------------ |
| `description` | str  | `''`    | Project description for README.md.                                                                                       |
| `is_public`   | bool | `false` | Set to `true` for public repositories. Enables commitlint rule to prevent external GitHub references in commit messages. |

## Template Development

The following files are used by Copier and are not part of the generated project:

- `copier.yml` - Copier configuration
- `.copier-answers.yaml.jinja` - Template for storing answers in downstream projects
- `README.md.jinja` - Template for the README in downstream projects
- `README.md` - This file (documentation for the template itself)
