#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
}

# Prints the root jobs (no `needs:`) that lack the bootstrap-push skip condition.
unguarded_root_jobs() {
  awk '
    function flush() {
      if (job != "" && !has_needs && !has_guard) print job
    }
    /^jobs:$/ { in_jobs = 1; next }
    !in_jobs { next }
    /^  [A-Za-z0-9_-]+:$/ {
      flush()
      job = $1; has_needs = 0; has_guard = 0
      next
    }
    /^    needs:/ { has_needs = 1 }
    index($0, "    if: \"!contains(github.event.head_commit.added, '"'"'.github/workflows/bootstrap.yml'"'"')") == 1 { has_guard = 1 }
    END { flush() }
  ' "$1"
}

@test "lockfile-dependent workflows skip root jobs on the push that adds bootstrap.yml" {
  local dir workflow checked=0
  for dir in "$REPO_ROOT"/generated/*/; do
    [ -f "$dir.github/workflows/bootstrap.yml" ] || continue
    for workflow in test storybook vrt docker-publish; do
      [ -f "$dir.github/workflows/$workflow.yml" ] || continue
      run unguarded_root_jobs "$dir.github/workflows/$workflow.yml"
      [ "$status" -eq 0 ]
      [ -z "$output" ] || {
        echo "$dir.github/workflows/$workflow.yml: $output"
        return 1
      }
      checked=$((checked + 1))
    done
  done
  [ "$checked" -gt 0 ]
}
