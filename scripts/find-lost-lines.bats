#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"

  TEST_DIR=$(mktemp -d)
  OLD_RENDER="$TEST_DIR/old-render"
  mkdir -p "$OLD_RENDER"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "reports repo-specific lines dropped when a file becomes a symlink" {
  printf '# Rules\n\nshared rule\n' > "$OLD_RENDER/CLAUDE.md"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'EOF'
diff --git a/CLAUDE.md b/CLAUDE.md
deleted file mode 100644
--- a/CLAUDE.md
+++ /dev/null
@@ -1,6 +0,0 @@
-# Rules
-
-shared rule
-
-## Product spec
-  - only this repo has it
diff --git a/CLAUDE.md b/CLAUDE.md
new file mode 120000
--- /dev/null
+++ b/CLAUDE.md
@@ -0,0 +1 @@
+AGENTS.md
diff --git a/AGENTS.md b/AGENTS.md
new file mode 100644
--- /dev/null
+++ b/AGENTS.md
@@ -0,0 +1,3 @@
+# Rules
+
+shared rule
EOF

  [ "$status" -eq 1 ]
  [ "${lines[0]}" = $'CLAUDE.md\t## Product spec' ]
  [ "${lines[1]}" = $'CLAUDE.md\t- only this repo has it' ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "reports removed lines written only in non-ASCII text" {
  printf '# Rules\n' > "$OLD_RENDER/CLAUDE.md"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'EOF'
diff --git a/CLAUDE.md b/CLAUDE.md
--- a/CLAUDE.md
+++ b/CLAUDE.md
@@ -1,3 +1 @@
 # Rules
-製品仕様
-- 日本語で返信する
EOF

  [ "$status" -eq 1 ]
  [ "${lines[0]}" = $'CLAUDE.md\t製品仕様' ]
  [ "${lines[1]}" = $'CLAUDE.md\t- 日本語で返信する' ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "ignores lines the template owned" {
  printf 'node = "24.0"\nbun = "1.3"\n' > "$OLD_RENDER/.mise.toml"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'EOF'
diff --git a/.mise.toml b/.mise.toml
--- a/.mise.toml
+++ b/.mise.toml
@@ -1,2 +1,2 @@
-node = "24.0"
+node = "24.2"
 bun = "1.3"
EOF

  [ "$status" -eq 0 ]
}

@test "ignores lines moved into another file" {
  printf 'shared rule\n' > "$OLD_RENDER/CLAUDE.md"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'EOF'
diff --git a/CLAUDE.md b/CLAUDE.md
--- a/CLAUDE.md
+++ b/CLAUDE.md
@@ -1,2 +0,0 @@
-shared rule
-repo rule
diff --git a/AGENTS.md b/AGENTS.md
new file mode 100644
--- /dev/null
+++ b/AGENTS.md
@@ -0,0 +1,2 @@
+shared rule
+  repo rule
EOF

  [ "$status" -eq 0 ]
}

@test "ignores a repo-specific line kept on the before-updating side of a conflict" {
  printf 'node = "24.0"\n' > "$OLD_RENDER/.mise.toml"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'EOF'
diff --git a/.mise.toml b/.mise.toml
--- a/.mise.toml
+++ b/.mise.toml
@@ -1 +1,5 @@
-node = "24.1"
+<<<<<<< before updating
+node = "24.1"
+=======
+node = "24.2"
+>>>>>>> after updating
EOF

  [ "$status" -eq 0 ]
}

@test "ignores files the template did not render" {
  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'EOF'
diff --git a/pnpm-lock.yaml b/pnpm-lock.yaml
--- a/pnpm-lock.yaml
+++ b/pnpm-lock.yaml
@@ -1 +1 @@
-  version: 1.0.0
+  version: 1.0.1
EOF

  [ "$status" -eq 0 ]
}

@test "ignores generic lines and .copier-answers.yml" {
  printf '_commit: v0.11.1\n{\n}\n' > "$OLD_RENDER/.copier-answers.yml"
  printf '{\n}\n' > "$OLD_RENDER/package.json"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'EOF'
diff --git a/.copier-answers.yml b/.copier-answers.yml
--- a/.copier-answers.yml
+++ b/.copier-answers.yml
@@ -1 +1 @@
-old_param: value
+_commit: v0.11.2
diff --git a/package.json b/package.json
--- a/package.json
+++ b/package.json
@@ -1,3 +1,2 @@
-
-  ]
-},
+{
EOF

  [ "$status" -eq 0 ]
}

@test "does not treat a removed line starting with dashes as a diff header" {
  printf 'title\n' > "$OLD_RENDER/README.md"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'EOF'
diff --git a/README.md b/README.md
--- a/README.md
+++ b/README.md
@@ -1,2 +1 @@
 title
--- repo note
EOF

  [ "$status" -eq 1 ]
  [ "${lines[0]}" = $'README.md\t-- repo note' ]
}

@test "ignores a template-managed line whose version the repo bumped ahead of the template" {
  printf '    "knip": "6.34.0",\n  version: 2026.9.3\n- uses: taiki-e/install-action@1111111111111111111111111111111111111111 # v2.87.8\n' > "$OLD_RENDER/package.json"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'DIFF'
diff --git a/package.json b/package.json
--- a/package.json
+++ b/package.json
@@ -1,3 +1,3 @@
-    "knip": "6.35.0",
-  version: 2026.9.4
-- uses: taiki-e/install-action@9534c84618278caac52cb373bb164ed464dbd8af # v2.87.11
+    "knip": "6.35.1",
+  version: 2026.9.5
+- uses: taiki-e/install-action@2222222222222222222222222222222222222222 # v2.87.12
DIFF

  [ "$status" -eq 0 ]
}

@test "reports a repo-specific pin whose value was overwritten by another version" {
  printf 'shfmt = "3.14.1"\n' > "$OLD_RENDER/.mise.toml"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'DIFF'
diff --git a/.mise.toml b/.mise.toml
--- a/.mise.toml
+++ b/.mise.toml
@@ -1,2 +1,2 @@
-"aqua:jqlang/jq" = "1.8.1"
+"aqua:jqlang/jq" = "3.14.1"
 shfmt = "3.14.1"
DIFF

  [ "$status" -eq 1 ]
  [ "${lines[0]}" = $'.mise.toml\t"aqua:jqlang/jq" = "1.8.1"' ]
  [ "${#lines[@]}" -eq 1 ]
}

@test "reports a customized number that is not a version" {
  printf 'timeout-minutes: 10\n' > "$OLD_RENDER/test.yml"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'DIFF'
diff --git a/test.yml b/test.yml
--- a/test.yml
+++ b/test.yml
@@ -1 +1 @@
-timeout-minutes: 30
+timeout-minutes: 10
DIFF

  [ "$status" -eq 1 ]
  [ "${lines[0]}" = $'test.yml\ttimeout-minutes: 30' ]
}

@test "reports a customized decimal value that is not a version" {
  printf '  --radius: 0.625rem;\n' > "$OLD_RENDER/index.css"

  run "$SCRIPT_DIR/find-lost-lines" "$OLD_RENDER" << 'DIFF'
diff --git a/index.css b/index.css
--- a/index.css
+++ b/index.css
@@ -1 +1 @@
-  --radius: 0.5rem;
+  --radius: 0.625rem;
DIFF

  [ "$status" -eq 1 ]
  [ "${lines[0]}" = $'index.css\t--radius: 0.5rem;' ]
}
