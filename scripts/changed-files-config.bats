#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
}

@test "workflow gates use outputs that include deleted files" {
  local workflow
  for workflow in \
    .github/workflows/validate-template.yml \
    template/.github/workflows/vrt.yml.jinja \
    template/.github/workflows/storybook.yml.jinja \
    template/.github/workflows/_partials/monorepo-unit-tests.yml.jinja \
    template/.github/workflows/test.yml.jinja; do
    run rg -q 'outputs\.any_modified' "$REPO_ROOT/$workflow"
    [ "$status" -eq 0 ]
    run rg -q 'outputs\.any_changed' "$REPO_ROOT/$workflow"
    [ "$status" -eq 1 ]
  done
}

@test "workspace test matrix includes deleted files" {
  run rg -q 'outputs\.all_modified_files' \
    "$REPO_ROOT/template/.github/workflows/_partials/monorepo-unit-tests.yml.jinja"

  [ "$status" -eq 0 ]

  run rg -q 'outputs\.all_changed_files' \
    "$REPO_ROOT/template/.github/workflows/_partials/monorepo-unit-tests.yml.jinja"

  [ "$status" -eq 1 ]
}
