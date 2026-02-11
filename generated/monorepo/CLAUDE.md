# CLAUDE.md

## Test code rules

### Parameterize similar test cases with rstest

When multiple test functions share the same assertion logic and differ only in input/expected values, consolidate them into a single parameterized test using `#[rstest]` with `#[case]`.

Signs of violation:

- Two or more test functions with nearly identical bodies, differing only in literals
- Copy-pasted test logic with minor variations

Before (bad):

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

After (good):

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
