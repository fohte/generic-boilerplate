#!/usr/bin/env bats

install_deps_script() {
  yq '[.jobs[].steps[] | select(.name == "Install Playwright system dependencies")][0].run' "$1"
}

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  TEST_DIR="$(mktemp -d)"
  GENERATED_WORKFLOW="$REPO_ROOT/generated/monorepo-node-workspace/.github/workflows/test.yml"

  mkdir "$TEST_DIR/bin"
  export CALLS="$TEST_DIR/calls"
  : > "$CALLS"
  cat > "$TEST_DIR/bin/pnpm" << 'EOF'
#!/usr/bin/env bash
echo "pnpm $*" >> "$CALLS"
[ "$(grep -c '^pnpm' "$CALLS")" -lt "$PNPM_HANGS_UNTIL_CALL" ] || exit 0
exec sleep 30
EOF
  cat > "$TEST_DIR/bin/sudo" << 'EOF'
#!/usr/bin/env bash
echo "sudo $*" >> "$CALLS"
EOF
  chmod +x "$TEST_DIR/bin/pnpm" "$TEST_DIR/bin/sudo"
  export PATH="$TEST_DIR/bin:$PATH"

  # Only the time limit is shortened, so these tests exercise the real `timeout`.
  install_deps_script "$GENERATED_WORKFLOW" |
    sed -E 's/(timeout --kill-after=[^ ]+) [^ ]+/\1 1s/' > "$TEST_DIR/install-deps.sh"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "install-deps succeeds on a later attempt after an attempt hangs" {
  run env PNPM_HANGS_UNTIL_CALL=2 bash -e "$TEST_DIR/install-deps.sh"

  [ "$status" -eq 0 ]
  [ "$(grep -c '^pnpm' "$CALLS")" -eq 2 ]
}

@test "install-deps fails after every attempt hangs" {
  run env PNPM_HANGS_UNTIL_CALL=99 bash -e "$TEST_DIR/install-deps.sh"

  [ "$status" -eq 1 ]
  [ "$(grep -c '^pnpm' "$CALLS")" -eq 3 ]
}

@test "install-deps stops the root-owned apt-get before retrying" {
  run env PNPM_HANGS_UNTIL_CALL=2 bash -e "$TEST_DIR/install-deps.sh"

  [ "$(cat "$CALLS")" = "pnpm exec playwright install-deps chromium
sudo pkill -x apt-get
pnpm exec playwright install-deps chromium" ]
}

@test "validate-template runs the same install-deps script as generated workflows" {
  [ "$(install_deps_script "$REPO_ROOT/.github/workflows/validate-template.yml")" = "$(install_deps_script "$GENERATED_WORKFLOW")" ]
}

@test "browser installs leave apt to the retried install-deps step" {
  run grep -rlF -- '--with-deps' \
    "$REPO_ROOT/template/.github/workflows" \
    "$REPO_ROOT/generated/monorepo/.github/workflows" \
    "$REPO_ROOT/generated/monorepo-node-workspace/.github/workflows" \
    "$REPO_ROOT/.github/workflows"

  [ "$status" -eq 1 ]
}
