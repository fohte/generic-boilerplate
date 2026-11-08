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

# Prints one line for each build job that lacks the default branch check.
unguarded_build_jobs() {
  awk '
    function flush() {
      if (in_build && !has_guard) print "build"
    }
    /^  [A-Za-z0-9_-]+:$/ {
      flush()
      in_build = ($1 == "build:"); has_guard = 0
      next
    }
    /^    if: / && index($0, "(github.event_name != '"'"'push'"'"' || github.ref_name == github.event.repository.default_branch)") { has_guard = 1 }
    END { flush() }
  ' "$1"
}

@test "docker-publish build jobs skip pushes to a branch that is not the default" {
  local workflow
  for workflow in \
    "$REPO_ROOT/template/.github/workflows/docker-publish.yml.jinja" \
    "$REPO_ROOT"/generated/*/.github/workflows/docker-publish.yml; do
    [ -f "$workflow" ] || continue

    run unguarded_build_jobs "$workflow"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
  done
}
