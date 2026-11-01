#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
  EXTRACTOR="$SCRIPT_DIR/extract-pnpm-store-path-steps"
  TEMP_BASE="${AGENT_TMPDIR:-${RUNNER_TEMP:-${TMPDIR:-/tmp}}}"
  TEST_DIR="$(mktemp -d "$TEMP_BASE/pnpm-store-path.XXXXXX")"
  MOCK_BIN="$TEST_DIR/bin"
  OUTPUT_FILE="$TEST_DIR/github-output"
  STEP_STDOUT="$TEST_DIR/stdout"
  STEP_STDERR="$TEST_DIR/stderr"
  EXPECTED_OUTPUT="$TEST_DIR/expected-output"
  EXPECTED_STDERR="$TEST_DIR/expected-stderr"
  EXPECTED_STORE_PATH='/tmp/example pnpm store'
  # Pin the inventory so a workflow cannot silently disappear from runtime coverage.
  EXPECTED_WORKFLOW_COUNT=17
  EXPECTED_STORE_STEP_COUNT=41

  mkdir -p "$MOCK_BIN"
  cat > "$MOCK_BIN/pnpm" << 'BASH'
#!/usr/bin/env bash

if [[ -n "${PNPM_STDOUT:-}" ]]; then
  printf '%s\n' "$PNPM_STDOUT"
fi
if [[ -n "${PNPM_STDERR:-}" ]]; then
  printf '%s\n' "$PNPM_STDERR" >&2
fi
exit "${PNPM_EXIT_CODE:-0}"
BASH
  chmod +x "$MOCK_BIN/pnpm"

  WORKFLOWS=()
  while IFS= read -r workflow; do
    WORKFLOWS+=("$REPO_ROOT/$workflow")
  done < <(
    git -C "$REPO_ROOT" grep --untracked -l -F 'name: Get pnpm store directory' -- \
      ':(glob)generated/**/*.yml' \
      .github/workflows/validate-template.yml |
      sort
  )
}

teardown() {
  rm -r "$TEST_DIR"
}

execute_store_step() {
  local script=$1
  local exit_code=$2
  local stdout=$3
  local stderr=$4

  env \
    PATH="$MOCK_BIN:$PATH" \
    GITHUB_OUTPUT="$OUTPUT_FILE" \
    PNPM_EXIT_CODE="$exit_code" \
    PNPM_STDOUT="$stdout" \
    PNPM_STDERR="$stderr" \
    bash -e -c "$script" \
    > "$STEP_STDOUT" 2> "$STEP_STDERR"
}

assert_successful_store_step() {
  local script=$1

  : > "$OUTPUT_FILE"
  if execute_store_step "$script" 0 "$EXPECTED_STORE_PATH" ''; then
    status=0
  else
    status=$?
  fi

  [ "$status" -eq 0 ] || return 1
  [ ! -s "$STEP_STDOUT" ] || return 1
  [ ! -s "$STEP_STDERR" ] || return 1
  cmp -s "$EXPECTED_OUTPUT" "$OUTPUT_FILE"
}

assert_failed_store_step() {
  local script=$1

  : > "$OUTPUT_FILE"
  if execute_store_step "$script" 23 'partial result' 'pnpm error detail'; then
    status=0
  else
    status=$?
  fi

  [ "$status" -eq 23 ] || return 1
  [ ! -s "$OUTPUT_FILE" ] || return 1
  [ ! -s "$STEP_STDOUT" ] || return 1
  cmp -s "$EXPECTED_STDERR" "$STEP_STDERR"
}

for_each_store_step() {
  local callback=$1
  local step_count=0
  local workflow
  local steps_json
  local workflow_step_count
  local step_index
  local script

  [ "${#WORKFLOWS[@]}" -eq "$EXPECTED_WORKFLOW_COUNT" ] || return 1

  for workflow in "${WORKFLOWS[@]}"; do
    run bash "$EXTRACTOR" "$workflow"
    [ "$status" -eq 0 ] || return 1
    steps_json=$output
    workflow_step_count=$(jq 'length' <<< "$steps_json")

    for ((step_index = 0; step_index < workflow_step_count; step_index++)); do
      script=$(jq -r ".[$step_index]" <<< "$steps_json")
      "$callback" "$script" || return 1
      step_count=$((step_count + 1))
    done
  done

  [ "$step_count" -eq "$EXPECTED_STORE_STEP_COUNT" ]
}

@test "writes the exact store path output for every targeted workflow step" {
  printf 'path=%s\n' "$EXPECTED_STORE_PATH" > "$EXPECTED_OUTPUT"
  for_each_store_step assert_successful_store_step
}

@test "fails before writing the output when pnpm returns nonzero with stdout" {
  printf 'pnpm error detail\n' > "$EXPECTED_STDERR"
  for_each_store_step assert_failed_store_step
}

@test "rejects a workflow with no pnpm store path step" {
  cat > "$TEST_DIR/workflow.yml" << 'YAML'
jobs:
  verify:
    steps:
      - run: echo ready
YAML

  run bash "$EXTRACTOR" "$TEST_DIR/workflow.yml"
  [ "$status" -eq 1 ]
  [[ "$output" == *"found 0"* ]]
}
