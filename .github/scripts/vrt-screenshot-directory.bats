#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

assert_screenshot_directory_matches_capture() {
  local workflow_file="$1"
  local job_name="$2"
  local setup_index
  local capture_index
  local setup_command
  local created_path
  local package_dir
  local screenshots_dir
  local expected_path

  setup_index="$(yq -r ".jobs[\"$job_name\"].steps | to_entries[] | select(.value.name == \"Create screenshots directory for empty viewport projects\") | .key" "$workflow_file")"
  capture_index="$(yq -r ".jobs[\"$job_name\"].steps | to_entries[] | select((.value.uses // \"\") | test(\"^fohte/storybook-vrt-workflows/vrt-capture@\")) | .key" "$workflow_file")"
  setup_command="$(yq -r ".jobs[\"$job_name\"].steps[] | select(.name == \"Create screenshots directory for empty viewport projects\") | .run" "$workflow_file")"
  package_dir="$(yq -r ".jobs[\"$job_name\"].steps[] | select((.uses // \"\") | test(\"^fohte/storybook-vrt-workflows/vrt-capture@\")) | .with[\"package-dir\"]" "$workflow_file")"
  screenshots_dir="$(yq -r ".jobs[\"$job_name\"].steps[] | select((.uses // \"\") | test(\"^fohte/storybook-vrt-workflows/vrt-capture@\")) | .with[\"screenshots-dir\"]" "$workflow_file")"

  [ "$setup_index" -lt "$capture_index" ]
  [ "$setup_command" != "null" ]

  created_path="${setup_command#mkdir -p }"
  created_path="${created_path#\"}"
  created_path="${created_path%\"}"
  package_dir="${package_dir#./}"
  [ "$package_dir" = "." ] && package_dir=""
  expected_path="${package_dir:+$package_dir/}${screenshots_dir}"

  [ "$created_path" = "$expected_path" ]
}

@test "root Storybook VRT prepares its screenshots directory before capture" {
  assert_screenshot_directory_matches_capture \
    "$REPO_ROOT/generated/node-vrt/.github/workflows/vrt.yml" \
    capture-root
}

@test "subpackage Storybook VRT prepares its screenshots directory before capture" {
  assert_screenshot_directory_matches_capture \
    "$REPO_ROOT/generated/monorepo-node-workspace/.github/workflows/vrt.yml" \
    capture-frontend
}
