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

# Lists the jobs that detect changes without comparing against the whole branch.
jobs_missing_branch_base() {
  yq -o=json "$1" | jq -r '
    def detects: (.uses // "") | contains("tj-actions/changed-files");
    .jobs | to_entries[]
    | select(any(.value.steps[]?; detects))
    | select(
        ([.value.steps[] | select(.id == "branch-base" and .if == "github.ref_name != github.event.repository.default_branch")] | length) != 1
        or (first(.value.steps[] | select((.uses // "") | contains("actions/checkout"))).with["fetch-depth"] != 0)
        or any(.value.steps[]; detects and .with.base_sha != "${{ steps.branch-base.outputs.sha }}")
      )
    | .key'
}

@test "Test workflows detect changes against the merge-base of the branch" {
  local workflow detecting=0
  for workflow in "$REPO_ROOT"/generated/*/.github/workflows/test.yml; do
    if grep -q 'tj-actions/changed-files' "$workflow"; then
      detecting=$((detecting + 1))
    fi

    run jobs_missing_branch_base "$workflow"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
  done
  [ "$detecting" -gt 0 ]
}

commit_file() {
  mkdir -p "$(dirname "$1")"
  echo change >> "$1"
  git add .
  git commit -qm "change $1"
}

# Builds a repo where main advanced after `feature` left it at $merge_base.
create_diverged_repo() {
  git init -q -b main "$BATS_TEST_TMPDIR/repo"
  cd "$BATS_TEST_TMPDIR/repo"
  git config user.email "bats@example.invalid"
  git config user.name "bats"
  commit_file base.txt
  merge_base=$(git rev-parse HEAD)
  git switch -qc feature
  commit_file backend/a.txt
  commit_file frontend/b.txt
  git switch -q main
  commit_file main-only.txt
  git switch -q feature
}

run_branch_base_step() {
  local script
  script=$(yq '.jobs.setup.steps[] | select(.id == "branch-base") | .run' \
    "$REPO_ROOT/generated/monorepo-node-workspace/.github/workflows/test.yml")
  export DEFAULT_BRANCH=main GITHUB_OUTPUT="$BATS_TEST_TMPDIR/github-output"
  run bash -e -c "$script"
}

@test "branch-base step outputs the commit where the branch left the default branch" {
  create_diverged_repo
  git update-ref refs/remotes/origin/main main

  run_branch_base_step

  [ "$status" -eq 0 ]
  [ "$(cat "$GITHUB_OUTPUT")" = "sha=$merge_base" ]
}

@test "branch-base step fails instead of falling back when the default branch is missing" {
  create_diverged_repo

  run_branch_base_step

  [ "$status" -ne 0 ]
}
