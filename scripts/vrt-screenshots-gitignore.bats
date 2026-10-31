#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  TEST_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_DIR"
}

assert_fixture_gitignore() {
  local fixture="$1"
  local gitignore_path="$2"
  local ignored_path="$3"
  local not_ignored_path="$4"
  local project_dir="$TEST_DIR/project"

  mkdir -p "$project_dir/$(dirname "$gitignore_path")"
  cp "$REPO_ROOT/generated/$fixture/$gitignore_path" "$project_dir/$gitignore_path"
  git -C "$project_dir" init -q

  run git -C "$project_dir" check-ignore -q -- "$ignored_path"
  [ "$status" -eq 0 ]

  run git -C "$project_dir" check-ignore -q -- "$not_ignored_path"
  [ "$status" -eq 1 ]
}

@test "root VRT screenshot paths are ignored without ignoring source screenshots" {
  assert_fixture_gitignore node-vrt .gitignore __screenshots__/desktop/capture.png src/__screenshots__/reference.png
}

@test "root VRT screenshot paths are ignored without Storybook" {
  assert_fixture_gitignore node-vrt-no-storybook .gitignore __screenshots__/custom-project/capture.png src/__screenshots__/reference.png
}

@test "workspace subpackage VRT screenshot paths are ignored at the root" {
  assert_fixture_gitignore monorepo-node-workspace .gitignore frontend/__screenshots__/desktop/capture.png frontend/src/__screenshots__/reference.png
}

@test "non-workspace subpackage VRT screenshot paths are ignored locally" {
  assert_fixture_gitignore monorepo frontend/.gitignore frontend/__screenshots__/desktop/capture.png frontend/src/__screenshots__/reference.png
}

@test "non-VRT projects do not ignore screenshot directories" {
  local project_dir="$TEST_DIR/project"

  mkdir -p "$project_dir"
  cp "$REPO_ROOT/generated/node/.gitignore" "$project_dir/.gitignore"
  git -C "$project_dir" init -q

  run git -C "$project_dir" check-ignore -q -- __screenshots__/capture.png
  [ "$status" -eq 1 ]
}
