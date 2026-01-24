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

@test "syncs TOML versions to .jinja template" {
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

  # Simulate Renovate update
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

  grep -q 'lefthook = "2.1.0"' template/.mise.toml.jinja
  grep -q 'actionlint = "1.8.0"' template/.mise.toml.jinja
  grep -q '"npm:@commitlint/cli" = "20.3.1"' template/.mise.toml.jinja
}

@test "preserves Jinja syntax in TOML template" {
  cat > template/.mise.toml.jinja << 'EOF'
[tools]
{% if type != 'node' -%}
"npm:@commitlint/cli" = "20.2.0"
{% endif -%}
EOF

  cat > generated/base/.mise.toml << 'EOF'
[tools]
"npm:@commitlint/cli" = "20.2.0"
EOF

  create_initial_commit

  cat > generated/base/.mise.toml << 'EOF'
[tools]
"npm:@commitlint/cli" = "20.3.1"
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  grep -q '{% if type' template/.mise.toml.jinja
  grep -q '{% endif' template/.mise.toml.jinja
}

@test "syncs JSON versions to .jinja template" {
  cat > template/package.json.jinja << 'EOF'
{
  "name": "{{ project_name }}",
  "devDependencies": {
    "vitest": "3.2.4"
  }
}
EOF

  cat > generated/base/package.json << 'EOF'
{
  "name": "base",
  "devDependencies": {
    "vitest": "3.2.4"
  }
}
EOF

  create_initial_commit

  cat > generated/base/package.json << 'EOF'
{
  "name": "base",
  "devDependencies": {
    "vitest": "3.3.0"
  }
}
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  grep -q '"vitest": "3.3.0"' template/package.json.jinja
}

@test "preserves Jinja syntax in JSON template" {
  cat > template/package.json.jinja << 'EOF'
{
  "name": "{{ project_name }}",
  "devDependencies": {
    "vitest": "3.2.4"
  }
}
EOF

  cat > generated/base/package.json << 'EOF'
{
  "name": "base",
  "devDependencies": {
    "vitest": "3.2.4"
  }
}
EOF

  create_initial_commit

  cat > generated/base/package.json << 'EOF'
{
  "name": "base",
  "devDependencies": {
    "vitest": "3.3.0"
  }
}
EOF

  git add .
  git commit -q -m "chore(deps): update"

  run "$REPO_ROOT/scripts/apply-renovate-patch" HEAD~1
  [ "$status" -eq 0 ]

  grep -q '{{ project_name }}' template/package.json.jinja
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
