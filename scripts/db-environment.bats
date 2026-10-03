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

teardown() {
  rm -rf "$TEST_DIR"
}

@test "db-up creates root development and test databases" {
  run "$REPO_ROOT/generated/node-db/scripts/db-up"

  [ "$status" -eq 0 ]
  [ "$(grep -Fxc 'compose port db 5432' "$DOCKER_LOG")" -eq 2 ]
  [ "$(grep -Fxc 'compose exec -T db psql --username node-db --dbname postgres --set ON_ERROR_STOP=1 --set db_name=node-db_dev' "$DOCKER_LOG")" -eq 1 ]
  [ "$(grep -Fxc 'compose exec -T db psql --username node-db --dbname postgres --set ON_ERROR_STOP=1 --set db_name=node-db_test' "$DOCKER_LOG")" -eq 1 ]
  assert_database_sql_calls 2
}

@test "db-up creates development and test databases for a DB subpackage" {
  run "$REPO_ROOT/generated/monorepo/scripts/db-up"

  [ "$status" -eq 0 ]
  [ "$(grep -Fxc 'compose port db 5432' "$DOCKER_LOG")" -eq 4 ]
  for database_name in monorepo_backend_dev monorepo_backend_test monorepo_frontend_dev monorepo_frontend_test; do
    [ "$(grep -Fxc "compose exec -T db psql --username monorepo --dbname postgres --set ON_ERROR_STOP=1 --set db_name=$database_name" "$DOCKER_LOG")" -eq 1 ]
  done
  assert_database_sql_calls 4
}

@test "db-url uses the published host port" {
  export MOCK_PORT=54321

  run "$REPO_ROOT/generated/node-db/scripts/db-url" . dev

  [ "$status" -eq 0 ]
  [ "$output" = "postgresql://node-db:node-db@127.0.0.1:54321/node-db_dev" ]
}

@test "db-url returns port zero when PostgreSQL is stopped" {
  export MOCK_PORT=down

  run "$REPO_ROOT/generated/node-db/scripts/db-url" . test

  [ "$status" -eq 0 ]
  [ "$output" = "postgresql://node-db:node-db@127.0.0.1:0/node-db_test" ]
}

@test "multiple DB subpackage mise configs resolve their own URLs" {
  export MOCK_PORT=down

  run bash -c 'mise -C "$1" env --json | jq -r "[.DATABASE_URL, .TEST_DATABASE_URL] | @tsv"' _ "$REPO_ROOT/generated/monorepo/backend"

  [ "$status" -eq 0 ]
  [ "$output" = $'postgresql://monorepo:monorepo@127.0.0.1:0/monorepo_backend_dev\tpostgresql://monorepo:monorepo@127.0.0.1:0/monorepo_backend_test' ]

  run bash -c 'mise -C "$1" env --json | jq -r "[.DATABASE_URL, .TEST_DATABASE_URL] | @tsv"' _ "$REPO_ROOT/generated/monorepo/frontend"

  [ "$status" -eq 0 ]
  [ "$output" = $'postgresql://monorepo:monorepo@127.0.0.1:0/monorepo_frontend_dev\tpostgresql://monorepo:monorepo@127.0.0.1:0/monorepo_frontend_test' ]
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
  [ "$output" = $'postgresql://node-db:node-db@127.0.0.1:0/node-db_dev\tpostgresql://node-db:node-db@127.0.0.1:0/node-db_test' ]
}

@test "database URL override files are gitignored where mise loads them" {
  for gitignore in \
    "$REPO_ROOT/generated/monorepo/.gitignore" \
    "$REPO_ROOT/generated/monorepo/backend/.gitignore" \
    "$REPO_ROOT/generated/monorepo/frontend/.gitignore"; do
    grep -Fxq '.env' "$gitignore"
    grep -Fxq '.env.local' "$gitignore"
  done
}

@test "database files are omitted when no package enables db" {
  [ ! -e "$REPO_ROOT/generated/base/compose.yaml" ]
  [ ! -e "$REPO_ROOT/generated/base/scripts/db-up" ]
  [ ! -e "$REPO_ROOT/generated/base/scripts/db-url" ]
}
