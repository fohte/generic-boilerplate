#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
}

@test "changed-files workflow gates use outputs that include deleted files" {
  local workflow_dirs=(
    "$REPO_ROOT/.github/workflows"
    "$REPO_ROOT/template/.github/workflows"
    "$REPO_ROOT/generated"
  )

  run git -C "$REPO_ROOT" grep -l 'tj-actions/changed-files' -- "${workflow_dirs[@]}"
  [ "$status" -eq 0 ]

  run git -C "$REPO_ROOT" grep -nE 'outputs\.(any_changed|all_changed_files)([^[:alnum:]_]|$)' -- "${workflow_dirs[@]}"
  [ "$status" -eq 1 ]

  run git -C "$REPO_ROOT" grep -nE 'outputs\.(any_modified|all_modified_files)([^[:alnum:]_]|$)' -- "${workflow_dirs[@]}"
  [ "$status" -eq 0 ]
}
