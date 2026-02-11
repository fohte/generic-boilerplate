# CLAUDE.md

## Project overview

This is a [Copier](https://copier.readthedocs.io/) template repository for generating boilerplate project scaffolding.

- `template/` — Copier template files. Editing these affects newly generated projects.
- `generated/` — Output generated from `template/`. Do not edit directly; regenerate from the template instead.
- Root config files (`.editorconfig`, `.prettierrc.yaml`, etc.) are shared via symlinks from `template/`.

## Test code rules

### Parameterize similar test cases instead of duplicating test functions

When multiple test functions share the same assertion logic and differ only in input/expected values, consolidate them into a single parameterized test.

Signs of violation:

- Two or more test functions with nearly identical bodies, differing only in literals
- Copy-pasted test logic with minor variations

Use the language's parameterized test mechanism:

- Rust: `rstest` with `#[rstest]` + `#[case]`
- Python: `pytest.mark.parametrize`
- TypeScript/JavaScript: `it.each` or `describe.each` (Jest/Vitest)
- Go: table-driven tests

Example (Rust, before — bad):

```rust
#[test]
fn test_parse_empty() {
    assert_eq!(parse(""), None);
}

#[test]
fn test_parse_whitespace() {
    assert_eq!(parse("   "), None);
}

#[test]
fn test_parse_valid() {
    assert_eq!(parse("hello"), Some("hello"));
}
```

Example (Rust, after — good):

```rust
#[rstest]
#[case::empty("", None)]
#[case::whitespace("   ", None)]
#[case::valid("hello", Some("hello"))]
fn test_parse(#[case] input: &str, #[case] expected: Option<&str>) {
    assert_eq!(parse(input), expected);
}
```

### Do not write tests that only verify test helpers

Tests should verify production code behavior. Tests that only exercise test helper functions, fixtures, or test utilities are unnecessary.

Signs of violation:

- A test whose only assertions target a helper defined in the test module or test utilities
- Tests named like `test_make_fixture`, `test_create_mock`, `test_build_test_data`
- Tests whose sole purpose is to assert that a builder, factory, or fake returns expected default values

Fix: remove the test. If the helper is complex enough to need its own tests, promote it to production code. Test helpers are validated indirectly by the tests that use them.
