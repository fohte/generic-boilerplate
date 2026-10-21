#!/usr/bin/env bats

setup_file() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  TEST_ROOT=$(mktemp -d)
  TEST_ROOT="$(cd "$TEST_ROOT" && pwd -P)"
  TEMPLATE_REPO="$TEST_ROOT/template"

  git clone --quiet --shared "$REPO_ROOT" "$TEMPLATE_REPO"
  git -C "$TEMPLATE_REPO" config user.name "Bats"
  git -C "$TEMPLATE_REPO" config user.email "bats@example.invalid"

  awk '/\.github\/workflows\/pr-title-check\.yml/ { print "  - \047{% if not pr_title_check %}.github/workflows/pr-title-check.yml{% endif %}\047"; next } { print }' \
    "$TEMPLATE_REPO/copier.yml" > "$TEST_ROOT/copier.yml"
  mv "$TEST_ROOT/copier.yml" "$TEMPLATE_REPO/copier.yml"

  workflow="$TEMPLATE_REPO/template/.github/workflows/pr-title-check.yml"
  {
    printf '# legacy template marker\n'
    cat "$workflow"
  } > "$TEST_ROOT/workflow.yml"
  mv "$TEST_ROOT/workflow.yml" "$workflow"

  git -C "$TEMPLATE_REPO" add copier.yml template/.github/workflows/pr-title-check.yml
  git -C "$TEMPLATE_REPO" commit --quiet -m "test: model legacy template"
  LEGACY_REF=$(git -C "$TEMPLATE_REPO" rev-parse HEAD)

  cp "$REPO_ROOT/copier.yml" "$TEMPLATE_REPO/copier.yml"
  cp "$REPO_ROOT/template/.github/workflows/pr-title-check.yml" \
    "$TEMPLATE_REPO/template/.github/workflows/pr-title-check.yml"
  git -C "$TEMPLATE_REPO" add copier.yml template/.github/workflows/pr-title-check.yml
  git -C "$TEMPLATE_REPO" commit --quiet -m "test: use current template config"
  CURRENT_REF=$(git -C "$TEMPLATE_REPO" rev-parse HEAD)

  export REPO_ROOT TEST_ROOT TEMPLATE_REPO LEGACY_REF CURRENT_REF
}

teardown_file() {
  rm -rf "$TEST_ROOT"
}

setup() {
  TEST_DIR=$(mktemp -d "$TEST_ROOT/case.XXXXXX")
}

teardown() {
  rm -rf "$TEST_DIR"
}

run_copier() {
  if command -v copier > /dev/null 2>&1; then
    copier "$@"
  else
    pipx run copier "$@"
  fi
}

copy_legacy_project() {
  run_copier copy --trust --defaults --vcs-ref "$LEGACY_REF" \
    --data-file "$1" "$TEMPLATE_REPO" "$2"
}

copy_current_project() {
  run_copier copy --trust --defaults --vcs-ref "$CURRENT_REF" \
    --data-file "$1" "$TEMPLATE_REPO" "$2"
}

update_project() {
  run_copier update --trust --defaults --vcs-ref "$CURRENT_REF" "$1"
}

assert_copier_succeeded() {
  if [ "$status" -ne 0 ]; then
    printf '%s\n' "$output" >&2
    return 1
  fi
}

initialize_project_repo() {
  local project=$1
  git -C "$project" init --quiet
  git -C "$project" config user.name "Bats"
  git -C "$project" config user.email "bats@example.invalid"
  git -C "$project" add --all
  git -C "$project" commit --quiet -m "test: initialize generated project"
}

remove_pr_title_check_answer() {
  local answers_file=$1
  awk '!/^pr_title_check:/' "$answers_file" > "$answers_file.tmp"
  mv "$answers_file.tmp" "$answers_file"
}

set_pr_title_check_answer() {
  local answers_file=$1
  local value=$2
  awk -v value="$value" '$1 == "pr_title_check:" { $2 = value } { print }' \
    "$answers_file" > "$answers_file.tmp"
  mv "$answers_file.tmp" "$answers_file"
}

@test "updates a legacy release workflow without conflicts and keeps local customization" {
  project="$TEST_DIR/project"
  run copy_legacy_project "$REPO_ROOT/tests/fixtures/base-release.yml" "$project"
  assert_copier_succeeded
  remove_pr_title_check_answer "$project/.copier-answers.yml"
  initialize_project_repo "$project"

  workflow="$project/.github/workflows/pr-title-check.yml"
  [ -f "$workflow" ]
  printf '\n# local customization\n' >> "$workflow"
  git -C "$project" add .github/workflows/pr-title-check.yml
  git -C "$project" commit --quiet -m "test: preserve local workflow customization"

  run update_project "$project"
  assert_copier_succeeded
  [ -f "$workflow" ]
  run grep -Eq '^(<<<<<<<|=======|>>>>>>>)' "$workflow"
  [ "$status" -eq 1 ]
  run grep -Fxq '# legacy template marker' "$workflow"
  [ "$status" -eq 1 ]
  grep -Fxq '# local customization' "$workflow"
}

@test "keeps the workflow excluded for legacy answers with releases disabled" {
  project="$TEST_DIR/project"
  run copy_legacy_project "$REPO_ROOT/tests/fixtures/base.yml" "$project"
  assert_copier_succeeded
  remove_pr_title_check_answer "$project/.copier-answers.yml"
  initialize_project_repo "$project"

  workflow="$project/.github/workflows/pr-title-check.yml"
  [ ! -f "$workflow" ]

  run update_project "$project"
  assert_copier_succeeded
  [ ! -f "$workflow" ]
}

@test "honors an explicit false answer when releases are enabled" {
  project="$TEST_DIR/project"
  data_file="$TEST_DIR/answers.yml"
  cp "$REPO_ROOT/tests/fixtures/base-release.yml" "$data_file"
  set_pr_title_check_answer "$data_file" false

  run copy_legacy_project "$data_file" "$project"
  assert_copier_succeeded
  initialize_project_repo "$project"
  workflow="$project/.github/workflows/pr-title-check.yml"
  [ ! -f "$workflow" ]

  run update_project "$project"
  assert_copier_succeeded
  [ ! -f "$workflow" ]
}

@test "honors an explicit true answer when releases are disabled" {
  project="$TEST_DIR/project"
  data_file="$TEST_DIR/answers.yml"
  cp "$REPO_ROOT/tests/fixtures/base.yml" "$data_file"
  set_pr_title_check_answer "$data_file" true

  run copy_legacy_project "$data_file" "$project"
  assert_copier_succeeded
  initialize_project_repo "$project"
  workflow="$project/.github/workflows/pr-title-check.yml"
  [ -f "$workflow" ]

  run update_project "$project"
  assert_copier_succeeded
  [ -f "$workflow" ]
}

@test "defaults new projects to the release setting when the answer is omitted" {
  project="$TEST_DIR/project"
  data_file="$TEST_DIR/answers.yml"
  cp "$REPO_ROOT/tests/fixtures/base-release.yml" "$data_file"
  remove_pr_title_check_answer "$data_file"

  run copy_current_project "$data_file" "$project"
  assert_copier_succeeded
  [ -f "$project/.github/workflows/pr-title-check.yml" ]
  grep -Eq '^pr_title_check: true$' "$project/.copier-answers.yml"
}
