#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
}

@test "allows job success when content loss was held for review" {
  run "$SCRIPT_DIR/content-loss-output-allows-job-success" <<'EOF'
LOST sample#3 (https://github.com/fohte/sample/pull/3)
  README.md: 1 line(s) lost
      project line
  HELD: auto-merge disabled, converted to draft
EOF

  [ "$status" -eq 0 ]
}

@test "fails the job when content loss cannot be verified" {
  run "$SCRIPT_DIR/content-loss-output-allows-job-success" <<'EOF'
UNVERIFIED sample#3 (https://github.com/fohte/sample/pull/3): could not fetch the PR diff
  HELD: auto-merge disabled, converted to draft
EOF

  [ "$status" -eq 1 ]
}

@test "fails the job when output includes both lost and unverified results" {
  run "$SCRIPT_DIR/content-loss-output-allows-job-success" <<'EOF'
LOST sample#3 (https://github.com/fohte/sample/pull/3)
  HELD: auto-merge disabled, converted to draft
UNVERIFIED other#4 (https://github.com/fohte/other/pull/4): could not render the old template version
EOF

  [ "$status" -eq 1 ]
}

@test "fails the job when the lost PR was not confirmed as held" {
  run "$SCRIPT_DIR/content-loss-output-allows-job-success" <<'EOF'
LOST sample#3 (https://github.com/fohte/sample/pull/3)
  HOLD FAILED: could not disable auto-merge / convert to draft
EOF

  [ "$status" -eq 1 ]
}
