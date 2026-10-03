#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

  TEST_DIR=$(mktemp -d)
  MOCK_BIN="$TEST_DIR/bin"
  NODE_DB_DIR="$TEST_DIR/node-db"
  MONOREPO_DIR="$TEST_DIR/monorepo"
  mkdir -p "$MOCK_BIN"
  cp -R "$REPO_ROOT/generated/node-db" "$NODE_DB_DIR"
  cp -R "$REPO_ROOT/generated/monorepo" "$MONOREPO_DIR"

  jq '.scripts["db:migrate"] = "true"' "$NODE_DB_DIR/package.json" > "$TEST_DIR/node-db-package.json"
  mv "$TEST_DIR/node-db-package.json" "$NODE_DB_DIR/package.json"
  jq '.scripts["db:migrate"] = "true"' "$MONOREPO_DIR/frontend/package.json" > "$TEST_DIR/frontend-package.json"
  mv "$TEST_DIR/frontend-package.json" "$MONOREPO_DIR/frontend/package.json"
  mkdir -p "$MONOREPO_DIR/backend/migration"
  touch "$MONOREPO_DIR/backend/migration/Cargo.toml"

  export DOCKER_LOG="$TEST_DIR/docker.log"
  export COMMAND_LOG="$TEST_DIR/command.log"
  : > "$DOCKER_LOG"
  : > "$COMMAND_LOG"

  cat > "$MOCK_BIN/docker" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "$DOCKER_LOG"
if [[ "$1 $2" == "compose port" ]]; then
  printf '127.0.0.1:%s\n' "${MOCK_PORT:-54321}"
fi
EOF

  for command in pnpm cargo tbls; do
    cat > "$MOCK_BIN/$command" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s|%s|%s|%s\n' '$command' "\$PWD" "\$*" "\${DATABASE_URL:-\${TBLS_DSN:-}}" >> "\$COMMAND_LOG"
if [[ '$command' == pnpm || '$command' == cargo ]]; then
  exit "\${MOCK_MIGRATION_STATUS:-0}"
fi
EOF
    chmod +x "$MOCK_BIN/$command"
  done
  chmod +x "$MOCK_BIN/docker"

  export PATH="$MOCK_BIN:$PATH"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "db-doc removes the root disposable database after generation" {
  run "$NODE_DB_DIR/scripts/db-doc"

  [ "$status" -eq 0 ]
  grep -Fxq 'compose up -d --wait db' "$DOCKER_LOG"
  database_name="$(sed -nE 's/^compose exec -T db createdb --username node-db (node-db_doc_[0-9]+)$/\1/p' "$DOCKER_LOG")"
  [ -n "$database_name" ]
  grep -Fxq "compose exec -T db dropdb --username node-db --if-exists --force $database_name" "$DOCKER_LOG"
}

@test "db-doc passes the disposable DSN to tbls doc and lint" {
  run "$NODE_DB_DIR/scripts/db-doc"

  [ "$status" -eq 0 ]
  database_name="$(sed -nE 's/^compose exec -T db createdb --username node-db (node-db_doc_[0-9]+)$/\1/p' "$DOCKER_LOG")"
  dsn="postgresql://node-db:node-db@127.0.0.1:54321/$database_name?sslmode=disable"
  grep -Fxq "tbls|$NODE_DB_DIR|doc --rm-dist -c .tbls.yml|$dsn" "$COMMAND_LOG"
  grep -Fxq "tbls|$NODE_DB_DIR|lint -c .tbls.yml|$dsn" "$COMMAND_LOG"
}

@test "db-doc uses each DB subpackage migration command" {
  run "$MONOREPO_DIR/scripts/db-doc"

  [ "$status" -eq 0 ]
  frontend_db="$(sed -nE 's/^compose exec -T db createdb --username monorepo (monorepo_doc_frontend_[0-9]+)$/\1/p' "$DOCKER_LOG")"
  backend_db="$(sed -nE 's/^compose exec -T db createdb --username monorepo (monorepo_doc_backend_[0-9]+)$/\1/p' "$DOCKER_LOG")"
  [ -n "$frontend_db" ]
  [ -n "$backend_db" ]
  grep -Fxq "pnpm|$MONOREPO_DIR/frontend|run db:migrate|postgresql://monorepo:monorepo@127.0.0.1:54321/$frontend_db" "$COMMAND_LOG"
  grep -Fxq "cargo|$MONOREPO_DIR/backend|run -q -p migration -- up|postgresql://monorepo:monorepo@127.0.0.1:54321/$backend_db" "$COMMAND_LOG"
  grep -Fxq "compose exec -T db dropdb --username monorepo --if-exists --force $frontend_db" "$DOCKER_LOG"
  grep -Fxq "compose exec -T db dropdb --username monorepo --if-exists --force $backend_db" "$DOCKER_LOG"
}

@test "db-doc preserves migration failure status and removes the database" {
  export MOCK_MIGRATION_STATUS=17

  run "$NODE_DB_DIR/scripts/db-doc"

  [ "$status" -eq 17 ]
  database_name="$(sed -nE 's/^compose exec -T db createdb --username node-db (node-db_doc_[0-9]+)$/\1/p' "$DOCKER_LOG")"
  grep -Fxq "compose exec -T db dropdb --username node-db --if-exists --force $database_name" "$DOCKER_LOG"
}

@test "db-doc skips packages without default migration setup" {
  jq 'del(.scripts["db:migrate"])' "$NODE_DB_DIR/package.json" > "$TEST_DIR/node-db-package.json"
  mv "$TEST_DIR/node-db-package.json" "$NODE_DB_DIR/package.json"

  run "$NODE_DB_DIR/scripts/db-doc"

  [ "$status" -eq 0 ]
  ! grep -Fq 'createdb' "$DOCKER_LOG"
  [ ! -s "$COMMAND_LOG" ]
}

@test "db-doc skips Rust packages without a default migration crate" {
  rm "$MONOREPO_DIR/backend/migration/Cargo.toml"

  run "$MONOREPO_DIR/scripts/db-doc"

  [ "$status" -eq 0 ]
  ! grep -Fq 'createdb --username monorepo monorepo_doc_backend_' "$DOCKER_LOG"
  ! grep -Fq "cargo|$MONOREPO_DIR/backend|" "$COMMAND_LOG"
}
