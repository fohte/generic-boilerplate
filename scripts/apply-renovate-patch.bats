#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"

  git init -q
  git config user.email "test@example.com"
  git config user.name "Test"

  mkdir -p template generated/base
}

teardown() {
  rm -rf "$TEST_DIR"
}

create_initial_commit() {
  git add .
  git commit -q -m "Initial commit"
}

@test "syncs TOML versions and preserves Jinja syntax" {
  cat > template/.mise.toml.jinja << 'EOF'
[tools]
lefthook = "2.0.12"
actionlint = "1.7.9"
{% if type != 'node' -%}
"npm:@commitlint/cli" = "20.2.0"
{% endif -%}
EOF

  cat > generated/base/.mise.toml << 'EOF'
[tools]
lefthook = "2.0.12"
actionlint = "1.7.9"
"npm:@commitlint/cli" = "20.2.0"
EOF

  create_initial_commit

  cat > generated/base/.mise.toml << 'EOF'
[tools]
lefthook = "2.1.0"
actionlint = "1.8.0"
"npm:@commitlint/cli" = "20.3.1"
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  diff -u template/.mise.toml.jinja - << 'EOF'
[tools]
lefthook = "2.1.0"
actionlint = "1.8.0"
{% if type != 'node' -%}
"npm:@commitlint/cli" = "20.3.1"
{% endif -%}
EOF
}

@test "syncs JSON versions and preserves Jinja syntax" {
  cat > template/package.json.jinja << 'EOF'
{
  "name": "{{ project_name }}",
  "devDependencies": {
    "eslint": "9.18.0",
    "prettier": "3.4.2",
    "vitest": "3.2.4"
  }
}
EOF

  cat > generated/base/package.json << 'EOF'
{
  "name": "base",
  "devDependencies": {
    "eslint": "9.18.0",
    "prettier": "3.4.2",
    "vitest": "3.2.4"
  }
}
EOF

  create_initial_commit

  # Renovate updates only vitest, others stay the same
  cat > generated/base/package.json << 'EOF'
{
  "name": "base",
  "devDependencies": {
    "eslint": "9.18.0",
    "prettier": "3.4.2",
    "vitest": "3.3.0"
  }
}
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  diff -u template/package.json.jinja - << 'EOF'
{
  "name": "{{ project_name }}",
  "devDependencies": {
    "eslint": "9.18.0",
    "prettier": "3.4.2",
    "vitest": "3.3.0"
  }
}
EOF
}

@test "reports no changes when generated/ is unchanged" {
  cat > template/.mise.toml.jinja << 'EOF'
[tools]
lefthook = "2.0.12"
EOF

  cat > generated/base/.mise.toml << 'EOF'
[tools]
lefthook = "2.0.12"
EOF

  create_initial_commit

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD
  [ "$status" -eq 0 ]
  [[ "$output" == *"No files changed"* ]]
}

@test "does not count already-synced versions" {
  cat > template/.mise.toml.jinja << 'EOF'
[tools]
lefthook = "2.0.12"
actionlint = "1.7.9"
EOF

  cat > generated/base/.mise.toml << 'EOF'
[tools]
lefthook = "2.0.12"
actionlint = "1.7.9"
EOF

  create_initial_commit

  # Renovate updates only actionlint, lefthook stays the same
  cat > generated/base/.mise.toml << 'EOF'
[tools]
lefthook = "2.0.12"
actionlint = "1.8.0"
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  # Should report only 1 version synced (actionlint), not 2 (lefthook already matches)
  [[ "$output" == *"Synced 1 version"* ]]
}

@test "succeeds when all versions already in sync" {
  cat > template/.mise.toml.jinja << 'EOF'
[tools]
lefthook = "2.0.12"
EOF

  cat > generated/base/.mise.toml << 'EOF'
[tools]
lefthook = "2.0.11"
EOF

  create_initial_commit

  # Renovate updates to same version as template already has
  cat > generated/base/.mise.toml << 'EOF'
[tools]
lefthook = "2.0.12"
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  # Should succeed with "Already in sync" message, not fail
  [[ "$output" == *"Already in sync"* ]]
}

@test "syncs YAML unquoted versions with v prefix and preserves Jinja syntax" {
  cat > template/lefthook.yml.jinja << 'EOF'
remotes:
  - git_url: https://github.com/fohte/lefthook-config
    ref: v0.1.12 # renovate: datasource=github-tags depName=fohte/lefthook-config
    configs:
      - lefthook.yml
{% if type == 'node' -%}
      - node.yml
{% endif -%}
EOF

  cat > generated/base/lefthook.yml << 'EOF'
remotes:
  - git_url: https://github.com/fohte/lefthook-config
    ref: v0.1.12 # renovate: datasource=github-tags depName=fohte/lefthook-config
    configs:
      - lefthook.yml
      - node.yml
EOF

  create_initial_commit

  cat > generated/base/lefthook.yml << 'EOF'
remotes:
  - git_url: https://github.com/fohte/lefthook-config
    ref: v0.1.13 # renovate: datasource=github-tags depName=fohte/lefthook-config
    configs:
      - lefthook.yml
      - node.yml
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  diff -u template/lefthook.yml.jinja - << 'EOF'
remotes:
  - git_url: https://github.com/fohte/lefthook-config
    ref: v0.1.13 # renovate: datasource=github-tags depName=fohte/lefthook-config
    configs:
      - lefthook.yml
{% if type == 'node' -%}
      - node.yml
{% endif -%}
EOF
}

@test "syncs YAML unquoted versions without v prefix" {
  cat > template/config.yml.jinja << 'EOF'
version: 1.2.3
name: {{ project_name }}
EOF

  cat > generated/base/config.yml << 'EOF'
version: 1.2.3
name: test
EOF

  create_initial_commit

  cat > generated/base/config.yml << 'EOF'
version: 1.3.0
name: test
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  diff -u template/config.yml.jinja - << 'EOF'
version: 1.3.0
name: {{ project_name }}
EOF
}

@test "syncs Cargo.toml pin version with = specifier" {
  cat > template/Cargo.toml.jinja << 'EOF'
[package]
name = "{{ project_name }}"
version = "0.1.0"

[dependencies]
tokio = "2.0.17"
serde = "1.0.0"
EOF

  cat > generated/base/Cargo.toml << 'EOF'
[package]
name = "test"
version = "0.1.0"

[dependencies]
tokio = "2.0.17"
serde = "1.0.0"
EOF

  create_initial_commit

  # Renovate pins tokio version
  cat > generated/base/Cargo.toml << 'EOF'
[package]
name = "test"
version = "0.1.0"

[dependencies]
tokio = "=2.0.17"
serde = "1.0.0"
EOF

  git add .
  git commit -q -m "chore(deps): pin tokio"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Synced 1 version"* ]]

  diff -u template/Cargo.toml.jinja - << 'EOF'
[package]
name = "{{ project_name }}"
version = "0.1.0"

[dependencies]
tokio = "=2.0.17"
serde = "1.0.0"
EOF
}

@test "syncs package.json with caret version specifier" {
  cat > template/package.json.jinja << 'EOF'
{
  "name": "{{ project_name }}",
  "dependencies": {
    "lodash": "4.17.21"
  }
}
EOF

  cat > generated/base/package.json << 'EOF'
{
  "name": "test",
  "dependencies": {
    "lodash": "4.17.21"
  }
}
EOF

  create_initial_commit

  # Renovate adds caret specifier
  cat > generated/base/package.json << 'EOF'
{
  "name": "test",
  "dependencies": {
    "lodash": "^4.17.21"
  }
}
EOF

  git add .
  git commit -q -m "chore(deps): update lodash"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Synced 1 version"* ]]

  diff -u template/package.json.jinja - << 'EOF'
{
  "name": "{{ project_name }}",
  "dependencies": {
    "lodash": "^4.17.21"
  }
}
EOF
}

@test "syncs package.json with tilde version specifier" {
  cat > template/package.json.jinja << 'EOF'
{
  "name": "{{ project_name }}",
  "dependencies": {
    "express": "4.18.0"
  }
}
EOF

  cat > generated/base/package.json << 'EOF'
{
  "name": "test",
  "dependencies": {
    "express": "4.18.0"
  }
}
EOF

  create_initial_commit

  # Renovate adds tilde specifier
  cat > generated/base/package.json << 'EOF'
{
  "name": "test",
  "dependencies": {
    "express": "~4.18.2"
  }
}
EOF

  git add .
  git commit -q -m "chore(deps): update express"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Synced 1 version"* ]]

  diff -u template/package.json.jinja - << 'EOF'
{
  "name": "{{ project_name }}",
  "dependencies": {
    "express": "~4.18.2"
  }
}
EOF
}

@test "syncs Cargo.toml with comparison specifiers" {
  cat > template/Cargo.toml.jinja << 'EOF'
[dependencies]
foo = "1.0.0"
bar = "2.0.0"
EOF

  cat > generated/base/Cargo.toml << 'EOF'
[dependencies]
foo = "1.0.0"
bar = "2.0.0"
EOF

  create_initial_commit

  # Renovate updates with comparison specifiers
  cat > generated/base/Cargo.toml << 'EOF'
[dependencies]
foo = ">=1.2.0"
bar = "^2.1.0"
EOF

  git add .
  git commit -q -m "chore(deps): update deps"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Synced 2 version"* ]]

  diff -u template/Cargo.toml.jinja - << 'EOF'
[dependencies]
foo = ">=1.2.0"
bar = "^2.1.0"
EOF
}

@test "detects already synced version with specifier" {
  cat > template/Cargo.toml.jinja << 'EOF'
[dependencies]
tokio = "=2.0.17"
EOF

  cat > generated/base/Cargo.toml << 'EOF'
[dependencies]
tokio = "2.0.16"
EOF

  create_initial_commit

  # Renovate updates to same pinned version as template already has
  cat > generated/base/Cargo.toml << 'EOF'
[dependencies]
tokio = "=2.0.17"
EOF

  git add .
  git commit -q -m "chore(deps): pin tokio"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already in sync"* ]]
}

@test "does not match version prefix in YAML unquoted versions" {
  # Regression test: ensure 1.2.3 does not match 1.2.30
  cat > template/config.yml.jinja << 'EOF'
version: 1.2.30
name: {{ project_name }}
EOF

  cat > generated/base/config.yml << 'EOF'
version: 1.2.30
name: test
EOF

  create_initial_commit

  # Renovate updates to 1.2.3 (different from template's 1.2.30)
  cat > generated/base/config.yml << 'EOF'
version: 1.2.3
name: test
EOF

  git add .
  git commit -q -m "chore(deps): update version"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  # Should sync, not report "Already in sync" (1.2.3 != 1.2.30)
  [[ "$output" == *"Synced 1 version"* ]]

  diff -u template/config.yml.jinja - << 'EOF'
version: 1.2.3
name: {{ project_name }}
EOF
}

@test "detects already synced caret version in YAML unquoted versions" {
  # Regression test: ensure ^1.2.3 is correctly escaped and matched
  cat > template/config.yml.jinja << 'EOF'
version: ^1.2.3
name: {{ project_name }}
EOF

  cat > generated/base/config.yml << 'EOF'
version: 1.2.2
name: test
EOF

  create_initial_commit

  # Renovate updates to ^1.2.3 (same as template)
  cat > generated/base/config.yml << 'EOF'
version: ^1.2.3
name: test
EOF

  git add .
  git commit -q -m "chore(deps): update version"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  # Should report "Already in sync" since ^1.2.3 matches template
  [[ "$output" == *"Already in sync"* ]]
}

@test "syncs GitHub Actions uses directive versions" {
  mkdir -p template/.github/workflows generated/base/.github/workflows

  cat > template/.github/workflows/ci.yml.jinja << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: suzuki-shunsuke/commit-action@v0.0.14
{% if enable_node -%}
      - uses: actions/setup-node@v4
{% endif -%}
EOF

  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: suzuki-shunsuke/commit-action@v0.0.14
      - uses: actions/setup-node@v4
EOF

  create_initial_commit

  # Renovate updates commit-action
  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: suzuki-shunsuke/commit-action@v0.1.0
      - uses: actions/setup-node@v4
EOF

  git add .
  git commit -q -m "chore(deps): update commit-action"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Synced 1 version"* ]]

  diff -u template/.github/workflows/ci.yml.jinja - << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: suzuki-shunsuke/commit-action@v0.1.0
{% if enable_node -%}
      - uses: actions/setup-node@v4
{% endif -%}
EOF
}

@test "syncs GitHub Actions uses with version suffix" {
  mkdir -p template/.github/workflows generated/base/.github/workflows

  cat > template/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: some-org/action@v1.2.3-beta.1
EOF

  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: some-org/action@v1.2.3-beta.1
EOF

  create_initial_commit

  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: some-org/action@v1.2.4-beta.2
EOF

  git add .
  git commit -q -m "chore(deps): update action"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Synced 1 version"* ]]

  diff -u template/.github/workflows/ci.yml - << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: some-org/action@v1.2.4-beta.2
EOF
}

@test "detects already synced GitHub Actions uses version" {
  mkdir -p template/.github/workflows generated/base/.github/workflows

  cat > template/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.1.0
EOF

  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.0.0
EOF

  create_initial_commit

  # Renovate updates to same version as template
  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.1.0
EOF

  git add .
  git commit -q -m "chore(deps): update checkout"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already in sync"* ]]
}

@test "syncs GitHub Actions uses with comment" {
  mkdir -p template/.github/workflows generated/base/.github/workflows

  cat > template/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.0.0 # some comment
EOF

  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.0.0 # some comment
EOF

  create_initial_commit

  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.1.0 # some comment
EOF

  git add .
  git commit -q -m "chore(deps): update checkout"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Synced 1 version"* ]]

  diff -u template/.github/workflows/ci.yml - << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.1.0 # some comment
EOF
}

@test "syncs GitHub Actions uses with major version only" {
  # Regression test: @v3 style versions (major only) should be matched
  mkdir -p template/.github/workflows generated/base/.github/workflows

  cat > template/.github/workflows/ci.yml.jinja << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: jdx/mise-action@v2
{% if enable_node -%}
      - uses: actions/setup-node@v4
{% endif -%}
EOF

  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: jdx/mise-action@v2
      - uses: actions/setup-node@v4
EOF

  create_initial_commit

  # Renovate updates mise-action from v2 to v3
  cat > generated/base/.github/workflows/ci.yml << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: jdx/mise-action@v3
      - uses: actions/setup-node@v4
EOF

  git add .
  git commit -q -m "chore(deps): update mise-action to v3"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Synced 1 version"* ]]

  diff -u template/.github/workflows/ci.yml.jinja - << 'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: jdx/mise-action@v3
{% if enable_node -%}
      - uses: actions/setup-node@v4
{% endif -%}
EOF
}

@test "excludes Cargo.lock from processing" {
  # Cargo.lock should be excluded because:
  # 1. It's regenerated by cargo generate-lockfile in the workflow
  # 2. The version key is too generic and would match all packages
  cat > template/Cargo.toml.jinja << 'EOF'
[package]
name = "{{ project_name }}"
version = "0.1.0"

[dependencies]
tokio = "1.0.0"
EOF

  cat > generated/base/Cargo.toml << 'EOF'
[package]
name = "test"
version = "0.1.0"

[dependencies]
tokio = "1.0.0"
EOF

  cat > generated/base/Cargo.lock << 'EOF'
[[package]]
name = "aho-corasick"
version = "1.1.3"

[[package]]
name = "tokio"
version = "1.0.0"
EOF

  create_initial_commit

  # Renovate updates tokio version in both Cargo.toml and Cargo.lock
  cat > generated/base/Cargo.toml << 'EOF'
[package]
name = "test"
version = "0.1.0"

[dependencies]
tokio = "1.1.0"
EOF

  cat > generated/base/Cargo.lock << 'EOF'
[[package]]
name = "aho-corasick"
version = "1.1.4"

[[package]]
name = "tokio"
version = "1.1.0"
EOF

  git add .
  git commit -q -m "chore(deps): update tokio"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  # Only Cargo.toml should be in changed files, not Cargo.lock
  [[ "$output" == *"generated/base/Cargo.toml"* ]]
  [[ "$output" != *"Cargo.lock"* ]]

  # Cargo.toml should be synced
  diff -u template/Cargo.toml.jinja - << 'EOF'
[package]
name = "{{ project_name }}"
version = "0.1.0"

[dependencies]
tokio = "1.1.0"
EOF
}
