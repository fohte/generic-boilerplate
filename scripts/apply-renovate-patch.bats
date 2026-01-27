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
