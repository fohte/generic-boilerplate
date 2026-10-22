#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
  EXTRACTOR="$SCRIPT_DIR/extract-workspace-install-command"
  TEMP_BASE="${AGENT_TMPDIR:-${RUNNER_TEMP:-${TMPDIR:-/tmp}}}"
  TEST_DIR="$(mktemp -d "$TEMP_BASE/workspace-install-command.XXXXXX")"
}

teardown() {
  rm -r "$TEST_DIR"
}

@test "extracts the generated install command from each workflow's YAML structure" {
  for workflow in test storybook vrt; do
    run bash "$EXTRACTOR" "$REPO_ROOT/generated/monorepo-node-workspace/.github/workflows/$workflow.yml"
    [ "$status" -eq 0 ]

    if [[ "$workflow" == test ]]; then
      [ "$output" = 'pnpm install --filter "{./frontend}..." --frozen-lockfile' ]
    else
      [ "$output" = 'pnpm install --filter "frontend..." --frozen-lockfile' ]
    fi
  done
}

@test "rejects a workflow with no filtered install command" {
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

@test "rejects multiple filtered install commands in one workflow" {
  cat > "$TEST_DIR/workflow.yml" << 'YAML'
jobs:
  verify:
    steps:
      - run: 'pnpm install --filter "frontend..." --frozen-lockfile'
      - run: 'pnpm install --filter "backend..." --frozen-lockfile'
YAML

  run bash "$EXTRACTOR" "$TEST_DIR/workflow.yml"
  [ "$status" -eq 1 ]
  [[ "$output" == *"found 2"* ]]
}

@test "rejects expressions left unresolved after replacing the matrix package" {
  cat > "$TEST_DIR/workflow.yml" << 'YAML'
jobs:
  verify:
    steps:
      - run: 'pnpm install --filter "{./${{ matrix.package }}}...${{ matrix.other }}" --frozen-lockfile'
YAML

  run bash "$EXTRACTOR" "$TEST_DIR/workflow.yml"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unresolved expression"* ]]
}
