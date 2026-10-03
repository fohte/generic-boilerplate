#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

  TEST_DIR=$(mktemp -d)
  MOCK_BIN="$TEST_DIR/bin"
  mkdir -p "$MOCK_BIN"

  export DOCKER_LOG="$TEST_DIR/docker.log"
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "$DOCKER_LOG"
if [[ "$1 $2" == "compose port" ]]; then
  if [[ "${MOCK_PORT:-}" == down ]]; then exit 1; fi
  printf '127.0.0.1:%s\n' "${MOCK_PORT:-54321}"
fi
EOF
  chmod +x "$MOCK_BIN/docker"

  export PATH="$MOCK_BIN:$PATH"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "db-up creates root development and test databases" {
  run "$REPO_ROOT/generated/node-db/scripts/db-up"

  [ "$status" -eq 0 ]
  [ "$(<"$DOCKER_LOG")" = $'compose up -d --wait\ncompose exec -T db psql --username node-db --dbname postgres --set ON_ERROR_STOP=1 --set db_name=node-db_dev\ncompose exec -T db psql --username node-db --dbname postgres --set ON_ERROR_STOP=1 --set db_name=node-db_test' ]
}

@test "db-up creates development and test databases for a DB subpackage" {
  run "$REPO_ROOT/generated/monorepo/scripts/db-up"

  [ "$status" -eq 0 ]
  [ "$(<"$DOCKER_LOG")" = $'compose up -d --wait\ncompose exec -T db psql --username monorepo --dbname postgres --set ON_ERROR_STOP=1 --set db_name=monorepo_backend_dev\ncompose exec -T db psql --username monorepo --dbname postgres --set ON_ERROR_STOP=1 --set db_name=monorepo_backend_test' ]
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

@test "subpackage mise config resolves its database URLs from the package directory" {
  export MOCK_PORT=down

  run bash -c 'mise -C "$1" env --json | jq -r "[.DATABASE_URL, .TEST_DATABASE_URL] | @tsv"' _ "$REPO_ROOT/generated/monorepo/backend"

  [ "$status" -eq 0 ]
  [ "$output" = $'postgresql://monorepo:monorepo@127.0.0.1:0/monorepo_backend_dev\tpostgresql://monorepo:monorepo@127.0.0.1:0/monorepo_backend_test' ]
}

@test "root mise config resolves a single-package database URL" {
  export MOCK_PORT=down

  run bash -c 'mise -C "$1" env --json | jq -r "[.DATABASE_URL, .TEST_DATABASE_URL] | @tsv"' _ "$REPO_ROOT/generated/node-db"

  [ "$status" -eq 0 ]
  [ "$output" = $'postgresql://node-db:node-db@127.0.0.1:0/node-db_dev\tpostgresql://node-db:node-db@127.0.0.1:0/node-db_test' ]
}

@test "database files are omitted when no package enables db" {
  [ ! -e "$REPO_ROOT/generated/base/compose.yaml" ]
  [ ! -e "$REPO_ROOT/generated/base/scripts/db-up" ]
  [ ! -e "$REPO_ROOT/generated/base/scripts/db-url" ]
}
