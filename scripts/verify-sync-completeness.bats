#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"

  # Create minimal copier template structure
  mkdir -p template tests/fixtures generated/base

  # Create copier.yml (required for copier to work)
  cat > copier.yml << 'EOF'
_subdirectory: template

project_name:
  type: str
  default: "test"
EOF

  # Create minimal template file
  cat > template/README.md.jinja << 'EOF'
# {{ project_name }}
EOF

  # Create fixture
  cat > tests/fixtures/base.yml << 'EOF'
project_name: base
EOF

  # Create matching generated output
  cat > generated/base/README.md << 'EOF'
# base
EOF
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "succeeds when generated matches template regeneration" {
  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 0 ]

  diff -u - <(echo "$output") << 'EOF'
Checking fixture: base
  OK

All fixtures are in sync.
EOF
}

@test "fails when generated does not match template regeneration" {
  cat > generated/base/README.md << 'EOF'
# wrong-name
EOF

  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 1 ]

  # Check key lines in output
  echo "$output" | grep -qx "Checking fixture: base"
  echo "$output" | grep -qx "::error::Sync incomplete for base"
  echo "$output" | grep -qx "Differences:"
  echo "$output" | grep -qx "Sync verification failed. Please ensure template/ changes are properly synced."
}

@test "detects missing file in generated directory" {
  cat > template/extra.txt << 'EOF'
extra content
EOF

  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 1 ]
  echo "$output" | grep -qx "::error::Sync incomplete for base"
}

@test "detects extra file in generated directory" {
  cat > generated/base/extra.txt << 'EOF'
extra content
EOF

  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 1 ]
  echo "$output" | grep -qx "::error::Sync incomplete for base"
}

@test "checks multiple fixtures" {
  mkdir -p generated/node

  cat > tests/fixtures/node.yml << 'EOF'
project_name: node
EOF

  cat > generated/node/README.md << 'EOF'
# node
EOF

  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 0 ]

  diff -u - <(echo "$output") << 'EOF'
Checking fixture: base
  OK
Checking fixture: node
  OK

All fixtures are in sync.
EOF
}
