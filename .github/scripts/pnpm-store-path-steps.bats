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
    WORKFLOWS+=("$workflow")
  done < <(
    rg -l --glob '*.yml' 'name: Get pnpm store directory' \
      "$REPO_ROOT/generated" \
      "$REPO_ROOT/.github/workflows/validate-template.yml" |
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
    bash --noprofile --norc -e -o pipefail -c "$script" \
    > "$STEP_STDOUT" 2> "$STEP_STDERR"
}

@test "writes the exact store path output for every targeted workflow step" {
  [ "${#WORKFLOWS[@]}" -eq 16 ]

  step_count=0
  printf 'path=%s\n' "$EXPECTED_STORE_PATH" > "$EXPECTED_OUTPUT"

  for workflow in "${WORKFLOWS[@]}"; do
    run bash "$EXTRACTOR" "$workflow"
    [ "$status" -eq 0 ]
    steps_json=$output
    workflow_step_count=$(jq 'length' <<< "$steps_json")

    for ((step_index = 0; step_index < workflow_step_count; step_index++)); do
      script=$(jq -r ".[$step_index]" <<< "$steps_json")
      : > "$OUTPUT_FILE"

      if execute_store_step "$script" 0 "$EXPECTED_STORE_PATH" ''; then
        status=0
      else
        status=$?
      fi

      [ "$status" -eq 0 ]
      [ ! -s "$STEP_STDOUT" ]
      [ ! -s "$STEP_STDERR" ]
      cmp -s "$EXPECTED_OUTPUT" "$OUTPUT_FILE"
      step_count=$((step_count + 1))
    done
  done

  [ "$step_count" -eq 38 ]
}

@test "fails before writing the output when pnpm returns nonzero with stdout" {
  [ "${#WORKFLOWS[@]}" -eq 16 ]

  step_count=0
  printf 'pnpm error detail\n' > "$EXPECTED_STDERR"

  for workflow in "${WORKFLOWS[@]}"; do
    run bash "$EXTRACTOR" "$workflow"
    [ "$status" -eq 0 ]
    steps_json=$output
    workflow_step_count=$(jq 'length' <<< "$steps_json")

    for ((step_index = 0; step_index < workflow_step_count; step_index++)); do
      script=$(jq -r ".[$step_index]" <<< "$steps_json")
      : > "$OUTPUT_FILE"

      if execute_store_step "$script" 23 'partial result' 'pnpm error detail'; then
        status=0
      else
        status=$?
      fi

      [ "$status" -eq 23 ]
      [ ! -s "$OUTPUT_FILE" ]
      [ ! -s "$STEP_STDOUT" ]
      cmp -s "$EXPECTED_STDERR" "$STEP_STDERR"
      step_count=$((step_count + 1))
    done
  done

  [ "$step_count" -eq 38 ]
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
