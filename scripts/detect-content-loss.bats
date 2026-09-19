#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"

  TEST_DIR=$(mktemp -d)
  MOCK_BIN="$TEST_DIR/bin"
  mkdir -p "$MOCK_BIN"

  DATA_FILE="$TEST_DIR/answers.yml"
  printf '%s\n' \
    '# Copier bookkeeping' \
    '_commit: v0.0.0' \
    '_src_path: https://example.invalid/template' \
    'type: base' \
    > "$DATA_FILE"

  GH_LOG="$TEST_DIR/gh.log"
  export GH_LOG
  export GH_MODE=clean
  export COPIER_MODE=clean
  export GH_LOST_PR=11

  cat > "$MOCK_BIN/gh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "$GH_LOG"
if [[ "$1 $2" == "pr diff" ]]; then
  if [[ "${GH_MODE}" == diff-failure ]]; then exit 1; fi
  if [[ "$GH_MODE" == lost || "$3" == "$GH_LOST_PR" ]]; then
    printf '%s\n' \
      'diff --git a/README.md b/README.md' \
      '--- a/README.md' \
      '+++ b/README.md' \
      '@@ -1 +0,0 @@' \
      '-repo line'
  fi
  exit 0
fi
if [[ "$1 $2" == "pr view" ]]; then
  echo true
fi
EOF
  chmod +x "$MOCK_BIN/gh"

  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -euo pipefail' \
    'if [[ "$COPIER_MODE" == failure ]]; then exit 1; fi' \
    'destination="${@: -1}"' \
    'data_file=' \
    'while [[ $# -gt 0 ]]; do' \
    '  if [[ "$1" == --data-file ]]; then data_file="$2"; shift 2; else shift; fi' \
    'done' \
    'if grep -q "^_" "$data_file"; then exit 1; fi' \
    'mkdir -p "$destination"' \
    'printf "template line\\n" > "$destination/README.md"' \
    > "$MOCK_BIN/copier"
  chmod +x "$MOCK_BIN/copier"

  LIST_USAGE_SCRIPT="$TEST_DIR/list-boilerplate-usage"
  cat > "$LIST_USAGE_SCRIPT" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' '[
  {
    "repo": "alpha",
    "commit": "HEAD",
    "params": {"type": "base"},
    "update_pr": {
      "number": 11,
      "url": "https://github.com/fohte/alpha/pull/11"
    }
  },
  {
    "repo": "beta",
    "commit": "HEAD",
    "params": {"type": "base"},
    "update_pr": {
      "number": 12,
      "url": "https://github.com/fohte/beta/pull/12"
    }
  }
]'
EOF
  chmod +x "$LIST_USAGE_SCRIPT"
  export DETECT_CONTENT_LOSS_LIST_USAGE="$LIST_USAGE_SCRIPT"

  export PATH="$MOCK_BIN:$PATH"
}

teardown() {
  rm -rf "$TEST_DIR"
}

run_direct() {
  run "$SCRIPT_DIR/detect-content-loss" \
    --pr-url https://github.com/fohte/example/pull/3 \
    --from HEAD \
    --data-file "$DATA_FILE"
}

EXPECTED_HOLD_LOG=$'pr diff 3 -R fohte/example\npr merge 3 -R fohte/example --disable-auto\npr ready 3 -R fohte/example --undo\npr view 3 -R fohte/example --json isDraft,autoMergeRequest --jq .isDraft and (.autoMergeRequest == null)'

@test "direct mode reports a clean PR" {
  run_direct

  [ "$status" -eq 0 ]
  [ "$output" = "OK example#3 (https://github.com/fohte/example/pull/3)" ]
  gh_log=$(<"$GH_LOG")
  [ "$gh_log" = "pr diff 3 -R fohte/example" ]
}

@test "direct mode holds a PR when content is lost" {
  export GH_MODE=lost

  run_direct

  [ "$status" -eq 1 ]
  [ "$output" = $'LOST example#3 (https://github.com/fohte/example/pull/3)\n  README.md: 1 line(s) lost\n      repo line\n  HELD: auto-merge disabled, converted to draft' ]
  gh_log=$(<"$GH_LOG")
  [ "$gh_log" = "$EXPECTED_HOLD_LOG" ]
}

@test "direct mode holds a PR when its diff cannot be fetched" {
  export GH_MODE=diff-failure

  run_direct

  [ "$status" -eq 1 ]
  [ "$output" = $'UNVERIFIED example#3 (https://github.com/fohte/example/pull/3): could not fetch the PR diff\n  HELD: auto-merge disabled, converted to draft' ]
  gh_log=$(<"$GH_LOG")
  [ "$gh_log" = "$EXPECTED_HOLD_LOG" ]
}

@test "direct mode holds a PR when the old template cannot be rendered" {
  export COPIER_MODE=failure

  run_direct

  [ "$status" -eq 1 ]
  [ "$output" = $'UNVERIFIED example#3 (https://github.com/fohte/example/pull/3): could not render the old template version\n  HELD: auto-merge disabled, converted to draft' ]
  gh_log=$(<"$GH_LOG")
  [ "$gh_log" = "$EXPECTED_HOLD_LOG" ]
}

@test "direct mode rejects an unsupported PR URL" {
  run "$SCRIPT_DIR/detect-content-loss" \
    --pr-url not-a-url \
    --from HEAD \
    --data-file "$DATA_FILE"

  [ "$status" -eq 1 ]
  [ "$output" = "UNVERIFIED: unsupported PR URL: not-a-url" ]
}

@test "direct mode requires all direct-check arguments" {
  run "$SCRIPT_DIR/detect-content-loss" \
    --pr-url https://github.com/fohte/example/pull/3

  [ "$status" -eq 1 ]
  [ "$output" = "--pr-url, --from, and --data-file must be provided together without repository arguments" ]
}

@test "repository-list mode checks every update PR and propagates failures" {
  run "$SCRIPT_DIR/detect-content-loss"

  [ "$status" -eq 1 ]
  [ "$output" = $'LOST alpha#11 (https://github.com/fohte/alpha/pull/11)\n  README.md: 1 line(s) lost\n      repo line\n  HELD: auto-merge disabled, converted to draft\nOK beta#12 (https://github.com/fohte/beta/pull/12)' ]
  gh_log=$(<"$GH_LOG")
  [ "$gh_log" = $'pr diff 11 -R fohte/alpha\npr merge 11 -R fohte/alpha --disable-auto\npr ready 11 -R fohte/alpha --undo\npr view 11 -R fohte/alpha --json isDraft,autoMergeRequest --jq .isDraft and (.autoMergeRequest == null)\npr diff 12 -R fohte/beta' ]
}
