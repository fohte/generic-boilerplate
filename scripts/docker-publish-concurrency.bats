#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
}

@test "docker-publish workflows queue pending runs without canceling in-progress runs" {
  local workflow
  for workflow in \
    "$REPO_ROOT/template/.github/workflows/docker-publish.yml.jinja" \
    "$REPO_ROOT"/generated/*/.github/workflows/docker-publish.yml; do
    [ -f "$workflow" ] || continue

    run grep -Fqx "  queue: max" "$workflow"
    [ "$status" -eq 0 ]

    run grep -Fqx "  cancel-in-progress: false" "$workflow"
    [ "$status" -eq 0 ]
  done
}

@test "docker-publish workflows ignore the unsupported queue key in actionlint" {
  local workflow config
  for workflow in "$REPO_ROOT"/generated/*/.github/workflows/docker-publish.yml; do
    [ -f "$workflow" ] || continue
    config="${workflow%/workflows/docker-publish.yml}/actionlint.yaml"

    [ -f "$config" ]
    run awk '
      /^  \.github\/workflows\/docker-publish\.yml:$/ { in_docker_publish = 1; next }
      /^  [^ ]/ { in_docker_publish = 0 }
      in_docker_publish && /unexpected key "queue" for "concurrency" section/ { found = 1 }
      END { exit !found }
    ' "$config"
    [ "$status" -eq 0 ]
  done
}
