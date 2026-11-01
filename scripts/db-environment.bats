#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

  TEST_DIR=$(mktemp -d)
  MOCK_BIN="$TEST_DIR/bin"
  mkdir -p "$MOCK_BIN"

  export DOCKER_LOG="$TEST_DIR/docker.log"
  export SQL_LOG="$TEST_DIR/sql.log"
  : > "$SQL_LOG"
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "$DOCKER_LOG"
if [[ " $* " == *" psql "* ]]; then
  cat >> "$SQL_LOG"
fi
if [[ "$1 $2" == "compose port" ]]; then
  if [[ "${MOCK_PORT:-}" == down ]]; then exit 1; fi
  printf '127.0.0.1:%s\n' "${MOCK_PORT:-54321}"
fi
EOF
  chmod +x "$MOCK_BIN/docker"

  export PATH="$MOCK_BIN:$PATH"
}

assert_database_sql_calls() {
  local call_count="$1"
  local call=0

  cat > "$TEST_DIR/expected-sql" <<'EOF'
SELECT format('CREATE DATABASE %I', :'db_name')
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = :'db_name'
)
\gexec
EOF

  : > "$TEST_DIR/expected-all-sql"
  while [ "$call" -lt "$call_count" ]; do
    cat "$TEST_DIR/expected-sql" >> "$TEST_DIR/expected-all-sql"
    call=$((call + 1))
  done

  cmp "$TEST_DIR/expected-all-sql" "$SQL_LOG"
}

workflow_job() {
  local workflow="$1"
  local job_name="$2"

  awk -v job="  ${job_name}:" '
    $0 == job { in_job = 1; print; next }
    in_job && /^  [[:alnum:]_-]+:/ { exit }
    in_job { print }
  ' "$workflow"
}

assert_database_setup_before_test() {
  local job="$1"
  local test_command="$2"
  local db_up_line
  local test_line

  db_up_line="$(grep -nF 'run: mise run db:up' <<<"$job" | cut -d: -f1)"
  test_line="$(grep -nF "$test_command" <<<"$job" | cut -d: -f1)"

  [ -n "$db_up_line" ]
  [ -n "$test_line" ]
  [ "$db_up_line" -lt "$test_line" ]
  [[ "$job" != *'env: false'* ]]
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "db-up creates root development and test databases" {
  run "$REPO_ROOT/generated/node-db/scripts/db-up"

  [ "$status" -eq 0 ]
  [ "$(grep -Fxc 'compose port db 5432' "$DOCKER_LOG")" -eq 2 ]
  [ "$(grep -Fxc 'compose exec -T db psql --username node_db --dbname postgres --set ON_ERROR_STOP=1 --set db_name=node_db_dev' "$DOCKER_LOG")" -eq 1 ]
  [ "$(grep -Fxc 'compose exec -T db psql --username node_db --dbname postgres --set ON_ERROR_STOP=1 --set db_name=node_db_test' "$DOCKER_LOG")" -eq 1 ]
  assert_database_sql_calls 2
}

@test "compose uses underscore database credentials and keeps the infra project name" {
  compose_file="$REPO_ROOT/generated/node-db/compose.yaml"

  grep -Fxq 'name: node-db-infra' "$compose_file"
  grep -Fxq '      # Existing data directories keep initialized roles and databases when these values change.' "$compose_file"
  grep -Fxq "      POSTGRES_USER: 'node_db'" "$compose_file"
  grep -Fxq "      POSTGRES_PASSWORD: 'node_db'" "$compose_file"
  grep -Fxq "      test: ['CMD-SHELL', 'pg_isready -U node_db -d postgres']" "$compose_file"
}

@test "db-up creates development and test databases for a DB subpackage" {
  run "$REPO_ROOT/generated/monorepo/scripts/db-up"

  [ "$status" -eq 0 ]
  [ "$(grep -Fxc 'compose port db 5432' "$DOCKER_LOG")" -eq 4 ]
  for database_name in sample_project_api_service_dev sample_project_api_service_test sample_project_frontend_dev sample_project_frontend_test; do
    [ "$(grep -Fxc "compose exec -T db psql --username sample_project --dbname postgres --set ON_ERROR_STOP=1 --set db_name=$database_name" "$DOCKER_LOG")" -eq 1 ]
  done
  assert_database_sql_calls 4
}

@test "db-url uses the published host port" {
  export MOCK_PORT=54321

  run "$REPO_ROOT/generated/node-db/scripts/db-url" . dev

  [ "$status" -eq 0 ]
  [ "$output" = "postgresql://node_db:node_db@127.0.0.1:54321/node_db_dev" ]
}

@test "db-url returns port zero when PostgreSQL is stopped" {
  export MOCK_PORT=down

  run "$REPO_ROOT/generated/node-db/scripts/db-url" . test

  [ "$status" -eq 0 ]
  [ "$output" = "postgresql://node_db:node_db@127.0.0.1:0/node_db_test" ]
}

@test "multiple DB subpackage mise configs resolve their own URLs" {
  export MOCK_PORT=down

  run bash -c 'mise -C "$1" env --json | jq -r "[.DATABASE_URL, .TEST_DATABASE_URL] | @tsv"' _ "$REPO_ROOT/generated/monorepo/api-service"

  [ "$status" -eq 0 ]
  [ "$output" = $'postgresql://sample_project:sample_project@127.0.0.1:0/sample_project_api_service_dev\tpostgresql://sample_project:sample_project@127.0.0.1:0/sample_project_api_service_test' ]

  run bash -c 'mise -C "$1" env --json | jq -r "[.DATABASE_URL, .TEST_DATABASE_URL] | @tsv"' _ "$REPO_ROOT/generated/monorepo/frontend"

  [ "$status" -eq 0 ]
  [ "$output" = $'postgresql://sample_project:sample_project@127.0.0.1:0/sample_project_frontend_dev\tpostgresql://sample_project:sample_project@127.0.0.1:0/sample_project_frontend_test' ]
}

@test "root mise omits ambiguous URLs when multiple packages enable DB" {
  run bash -c 'mise -C "$1" env --json | jq -r "[has(\"DATABASE_URL\"), has(\"TEST_DATABASE_URL\")] | @tsv"' _ "$REPO_ROOT/generated/monorepo"

  [ "$status" -eq 0 ]
  [ "$output" = $'false\tfalse' ]
}

@test "root mise config resolves a single-package database URL" {
  export MOCK_PORT=down

  run bash -c 'mise -C "$1" env --json | jq -r "[.DATABASE_URL, .TEST_DATABASE_URL] | @tsv"' _ "$REPO_ROOT/generated/node-db"

  [ "$status" -eq 0 ]
  [ "$output" = $'postgresql://node_db:node_db@127.0.0.1:0/node_db_dev\tpostgresql://node_db:node_db@127.0.0.1:0/node_db_test' ]
}

@test "mise exec refreshes inherited DB URLs after PostgreSQL starts" {
  export MOCK_PORT=54321

  run env DATABASE_URL=postgresql://stale:stale@127.0.0.1:0/stale TEST_DATABASE_URL=postgresql://stale:stale@127.0.0.1:0/stale mise -C "$REPO_ROOT/generated/node-db" exec -- bash -c 'printf "%s\\n%s\\n" "$DATABASE_URL" "$TEST_DATABASE_URL"'

  [ "$status" -eq 0 ]
  [ "$output" = $'postgresql://node_db:node_db@127.0.0.1:54321/node_db_dev\npostgresql://node_db:node_db@127.0.0.1:54321/node_db_test' ]
}

@test "database URL override files are gitignored where mise loads them" {
  for gitignore in \
    "$REPO_ROOT/generated/monorepo/.gitignore" \
    "$REPO_ROOT/generated/monorepo/api-service/.gitignore" \
    "$REPO_ROOT/generated/monorepo/frontend/.gitignore"; do
    grep -Fxq '.env' "$gitignore"
    grep -Fxq '.env.local' "$gitignore"
  done
}

@test "database files are omitted when no package enables db" {
  [ ! -e "$REPO_ROOT/generated/base/compose.yaml" ]
  [ ! -e "$REPO_ROOT/generated/base/scripts/db-up" ]
  [ ! -e "$REPO_ROOT/generated/base/scripts/db-url" ]
  [ ! -e "$REPO_ROOT/generated/base/scripts/db-doc" ]
  [ ! -e "$REPO_ROOT/generated/base/.tbls.yml" ]
  [ ! -e "$REPO_ROOT/generated/monorepo/.tbls.yml" ]
  [ ! -e "$REPO_ROOT/generated/monorepo-node-workspace/frontend/.tbls.yml" ]
  ! rg -q 'k1LoW/tbls|db:doc' "$REPO_ROOT/generated/base/.mise.toml"
}

@test "db-doc workflow includes a package-specific schema path" {
  grep -Fxq '            api-service/db-schema/**' "$REPO_ROOT/generated/monorepo/.github/workflows/test.yml"
}

@test "database-backed unit tests start PostgreSQL before resolving test URLs" {
  workflow="$REPO_ROOT/generated/node-db/.github/workflows/test.yml"
  job="$(workflow_job "$workflow" unit-test-run)"

  assert_database_setup_before_test "$job" 'mise exec -- pnpm run test'
}

@test "Rust root database-backed unit tests start PostgreSQL before tests" {
  workflow="$REPO_ROOT/generated/rust-db/.github/workflows/test.yml"
  job="$(workflow_job "$workflow" unit-test)"

  assert_database_setup_before_test "$job" 'mise exec -- cargo test'
}

@test "monorepo database-backed packages start PostgreSQL before tests" {
  workflow="$REPO_ROOT/generated/monorepo/.github/workflows/test.yml"
  frontend_job="$(workflow_job "$workflow" unit-test-frontend)"
  backend_job="$(workflow_job "$workflow" unit-test-api-service)"

  assert_database_setup_before_test "$frontend_job" 'mise exec -- pnpm run test'
  assert_database_setup_before_test "$backend_job" 'mise exec -- cargo llvm-cov'
}

@test "workspace database-backed Node and Rust tests start PostgreSQL before tests" {
  workflow="$REPO_ROOT/generated/monorepo-node-workspace-rust-go-db/.github/workflows/test.yml"
  node_job="$(workflow_job "$workflow" unit-test-run)"
  rust_job="$(workflow_job "$workflow" unit-test-backend)"

  assert_database_setup_before_test "$node_job" 'pnpm run test'
  assert_database_setup_before_test "$rust_job" 'mise exec -- cargo test'
}

@test "unit-test-worker skips database setup" {
  workflow="$REPO_ROOT/generated/monorepo-node-workspace-rust-go-db/.github/workflows/test.yml"
  worker_job="$(workflow_job "$workflow" unit-test-worker)"

  [[ "$worker_job" == *"Run Go tests"* ]]
  [[ "$worker_job" != *'run: mise run db:up'* ]]
  [[ "$worker_job" != *'mise exec --'* ]]
  [[ "$worker_job" != *'env: false'* ]]
}

@test "database-free node workflow skips database setup" {
  workflow="$REPO_ROOT/generated/node/.github/workflows/test.yml"
  root_job="$(workflow_job "$workflow" unit-test-run)"

  [[ "$root_job" != *'run: mise run db:up'* ]]
  [[ "$root_job" != *'mise exec --'* ]]
  [[ "$root_job" != *'env: false'* ]]
}

@test "Rust root skips database setup when only a subpackage enables it" {
  workflow="$REPO_ROOT/generated/rust-node-db/.github/workflows/test.yml"
  root_job="$(workflow_job "$workflow" unit-test-run)"

  [[ "$root_job" == *"Run tests"* ]]
  [[ "$root_job" != *'run: mise run db:up'* ]]
  [[ "$root_job" != *'mise exec -- cargo'* ]]
  [[ "$root_job" != *'env: false'* ]]
}

@test "Node root skips database setup when only a subpackage enables it" {
  workflow="$REPO_ROOT/generated/node-rust-subpackage-db/.github/workflows/test.yml"
  root_job="$(workflow_job "$workflow" unit-test-run)"

  [[ "$root_job" == *"Run tests"* ]]
  [[ "$root_job" != *'run: mise run db:up'* ]]
  [[ "$root_job" != *'mise exec --'* ]]
  [[ "$root_job" != *'env: false'* ]]
}

@test "database-enabled node subpackage starts PostgreSQL before tests" {
  workflow="$REPO_ROOT/generated/rust-node-db/.github/workflows/test.yml"
  node_job="$(workflow_job "$workflow" unit-test-docs)"

  [[ "$node_job" == *"Run tests"* ]]
  assert_database_setup_before_test "$node_job" 'mise exec -- pnpm run test'
}
