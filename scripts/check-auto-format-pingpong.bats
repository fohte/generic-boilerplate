#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

  TEST_DIR=$(mktemp -d)
  TEST_REPO="$TEST_DIR/repo"
  mkdir -p "$TEST_REPO"
  git -C "$TEST_REPO" init -q
  export GITHUB_OUTPUT="$TEST_DIR/github-output"
  : > "$GITHUB_OUTPUT"
}

teardown() {
  rm -rf "$TEST_DIR"
}

create_commit() {
  local message="$1"
  local author="$2"

  git -C "$TEST_REPO" -c "user.name=$author" -c user.email=test@example.invalid commit --allow-empty -q -m "$message"
}

run_check() {
  cd "$TEST_REPO"
  run "$REPO_ROOT/scripts/check-auto-format-pingpong"
}

@test "does not detect a ping-pong for a root commit" {
  create_commit "chore: initialize repository" "Example User"

  run_check

  [ "$status" -eq 0 ]
  [ "$(cat "$GITHUB_OUTPUT")" = $'skip_commit=false\nformat_pingpong=false' ]
}

@test "skips formatting and detects a bot regeneration after bot auto-format" {
  create_commit "style: auto-format" "formatter[bot]"
  create_commit "chore(generated): regenerate from template" "template[bot]"

  run_check

  [ "$status" -eq 0 ]
  [ "$(cat "$GITHUB_OUTPUT")" = $'skip_commit=true\nformat_pingpong=true' ]
}

@test "keeps skipping when the current commit is bot auto-format" {
  create_commit "chore(generated): regenerate from template" "template[bot]"
  create_commit "style: auto-format" "formatter[bot]"

  run_check

  [ "$status" -eq 0 ]
  [ "$(cat "$GITHUB_OUTPUT")" = $'skip_commit=true\nformat_pingpong=false' ]
}

@test "does not detect a ping-pong after an unrelated bot commit" {
  create_commit "chore(generated): regenerate from template" "template[bot]"
  create_commit "chore(generated): update snapshots" "template[bot]"

  run_check

  [ "$status" -eq 0 ]
  [ "$(cat "$GITHUB_OUTPUT")" = $'skip_commit=false\nformat_pingpong=false' ]
}

@test "does not detect a ping-pong when the parent auto-format commit was made by a human" {
  create_commit "style: auto-format" "Example User"
  create_commit "chore(generated): regenerate from template" "template[bot]"

  run_check

  [ "$status" -eq 0 ]
  [ "$(cat "$GITHUB_OUTPUT")" = $'skip_commit=false\nformat_pingpong=false' ]
}

@test "does not detect a ping-pong when the current commit was made by a human" {
  create_commit "style: auto-format" "formatter[bot]"
  create_commit "chore(generated): regenerate from template" "Example User"

  run_check

  [ "$status" -eq 0 ]
  [ "$(cat "$GITHUB_OUTPUT")" = $'skip_commit=false\nformat_pingpong=false' ]
}
