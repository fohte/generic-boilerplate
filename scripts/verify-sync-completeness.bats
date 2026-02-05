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

# Helper to check if output contains a line
assert_line() {
  local expected="$1"
  local line
  while IFS= read -r line; do
    if [[ "$line" == "$expected" ]]; then
      return 0
    fi
  done <<< "$output"
  echo "Expected line not found: $expected"
  echo "Actual output:"
  echo "$output"
  return 1
}

@test "succeeds when generated matches template regeneration" {
  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 0 ]
  assert_line "Checking fixture: base"
  assert_line "  OK"
  assert_line "All fixtures are in sync."
}

@test "fails when generated does not match template regeneration" {
  # Modify generated file to create a mismatch
  cat > generated/base/README.md << 'EOF'
# wrong-name
EOF

  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 1 ]
  assert_line "Checking fixture: base"
  assert_line "::error::Sync incomplete for base"
  assert_line "Differences:"
  assert_line "Sync verification failed. Please ensure template/ changes are properly synced."
}

@test "detects missing file in generated directory" {
  # Add a file to template that doesn't exist in generated
  cat > template/extra.txt << 'EOF'
extra content
EOF

  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 1 ]
  assert_line "::error::Sync incomplete for base"
}

@test "detects extra file in generated directory" {
  # Add a file to generated that shouldn't exist
  cat > generated/base/extra.txt << 'EOF'
extra content
EOF

  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 1 ]
  assert_line "::error::Sync incomplete for base"
}

@test "checks multiple fixtures" {
  # Create second fixture
  mkdir -p generated/node

  cat > tests/fixtures/node.yml << 'EOF'
project_name: node
EOF

  cat > generated/node/README.md << 'EOF'
# node
EOF

  run "$REPO_ROOT/scripts/verify-sync-completeness"
  [ "$status" -eq 0 ]
  assert_line "Checking fixture: base"
  assert_line "Checking fixture: node"
  assert_line "All fixtures are in sync."
}
