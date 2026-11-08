#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  WORKFLOWS=(
    "$REPO_ROOT"/template/.github/workflows/{vrt,storybook,docker-publish}.yml.jinja
    "$REPO_ROOT"/generated/*/.github/workflows/{vrt,storybook,docker-publish}.yml
  )
}

@test "push workflows trigger on both main and master" {
  local workflow
  for workflow in "${WORKFLOWS[@]}"; do
    [ -f "$workflow" ] || continue

    grep -Fqx "      - main" "$workflow"
    grep -Fqx "      - master" "$workflow"
  done
}

@test "push workflows do not assume main is the default branch" {
  local workflow
  for workflow in "${WORKFLOWS[@]}"; do
    [ -f "$workflow" ] || continue

    run grep -E "refs/heads/main|\|\| 'main'|--production-branch=main" "$workflow"
    [ "$status" -eq 1 ]
  done
}

@test "docker-publish skips pushes to a branch that is not the default" {
  local workflow
  for workflow in \
    "$REPO_ROOT/template/.github/workflows/docker-publish.yml.jinja" \
    "$REPO_ROOT"/generated/*/.github/workflows/docker-publish.yml; do
    [ -f "$workflow" ] || continue

    run grep -c "^  build:$" "$workflow"
    local jobs="$output"
    run grep -cF "(github.event_name != 'push' || github.ref_name == github.event.repository.default_branch)" "$workflow"
    [ "$output" -eq "$jobs" ]
  done
}
