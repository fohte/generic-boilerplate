#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  TEST_DIR="$(mktemp -d)"

  mkdir "$TEST_DIR/bin"
  export PNPM_CALLS="$TEST_DIR/pnpm-calls"
  : > "$PNPM_CALLS"
  cat > "$TEST_DIR/bin/pnpm" << 'EOF'
#!/usr/bin/env bash
echo "$*" >> "$PNPM_CALLS"
[ "$(wc -l < "$PNPM_CALLS")" -lt "$PNPM_HANGS_UNTIL_CALL" ] || exit 0
exec sleep 30
EOF
  export SUDO_CALLS="$TEST_DIR/sudo-calls"
  cat > "$TEST_DIR/bin/sudo" << 'EOF'
#!/usr/bin/env bash
echo "$*" >> "$SUDO_CALLS"
EOF
  chmod +x "$TEST_DIR/bin/pnpm" "$TEST_DIR/bin/sudo"
  export PATH="$TEST_DIR/bin:$PATH"

  # Only the time limit is shortened, so these tests exercise the real `timeout`.
  yq '[.jobs[].steps[] | select(.name == "Install Playwright system dependencies")][0].run' \
    "$REPO_ROOT/generated/monorepo-node-workspace/.github/workflows/test.yml" |
    sed -E 's/(timeout --kill-after=[^ ]+) [^ ]+/\1 1s/' > "$TEST_DIR/install-deps.sh"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "install-deps succeeds on a later attempt after an attempt hangs" {
  run env PNPM_HANGS_UNTIL_CALL=2 bash -e "$TEST_DIR/install-deps.sh"

  [ "$status" -eq 0 ]
  [ "$(wc -l < "$PNPM_CALLS")" -eq 2 ]
}

@test "install-deps fails after every attempt hangs" {
  run env PNPM_HANGS_UNTIL_CALL=99 bash -e "$TEST_DIR/install-deps.sh"

  [ "$status" -eq 1 ]
  [ "$(wc -l < "$PNPM_CALLS")" -eq 3 ]
}

@test "install-deps stops the root-owned apt-get before retrying" {
  run env PNPM_HANGS_UNTIL_CALL=2 bash -e "$TEST_DIR/install-deps.sh"

  [ "$(cat "$SUDO_CALLS")" = "pkill -x apt-get" ]
}

@test "browser installs leave apt to the retried install-deps step" {
  run grep -rlF -- '--with-deps' \
    "$REPO_ROOT/template/.github/workflows" \
    "$REPO_ROOT/generated/monorepo/.github/workflows" \
    "$REPO_ROOT/generated/monorepo-node-workspace/.github/workflows" \
    "$REPO_ROOT/.github/workflows"

  [ "$status" -eq 1 ]
}
