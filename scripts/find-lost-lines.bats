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
