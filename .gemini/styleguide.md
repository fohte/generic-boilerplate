# Gemini Code Assist Style Guide

## DO NOT suggest

- Changing versions or editions specified in config files

Assume version choices are intentional. Your training data may be outdated.

## Test code review rules

### Parameterize similar test cases instead of duplicating test functions

When multiple test functions share the same assertion logic and differ only in input/expected values, they should be consolidated into a single parameterized test.

Signs of violation:

- Two or more test functions with nearly identical bodies, differing only in literals (strings, numbers, expected values)
- Copy-pasted test logic with minor variations

Suggested fix:

- Use the language's parameterized test mechanism to consolidate the cases into one test function with multiple input sets
  - Rust: `rstest` crate with `#[rstest]` + `#[case]`
  - Python: `pytest.mark.parametrize`
  - TypeScript/JavaScript: `it.each` or `describe.each` (Jest/Vitest)
  - Go: table-driven tests
  - Other languages: equivalent parameterized/data-driven test framework

Example (Rust, before):

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

Example (Rust, after):

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

Test code should verify production (non-test) code behavior. Tests that only exercise test helper functions, fixtures, or test utilities are unnecessary and add maintenance burden without improving confidence in production code.

Signs of violation:

- A test function whose only assertions target a helper function defined in the test module or test utilities
- Tests named like `test_make_fixture`, `test_create_mock`, `test_build_test_data` that verify the correctness of setup/helper functions used by other tests
- Tests whose sole purpose is to assert that a builder, factory, or fake returns expected default values

Suggested fix:

- Remove the test entirely. If the helper is complex enough to need its own tests, consider whether it should be promoted to production code with its own proper test suite
- Trust that test helpers are validated indirectly by the tests that use them — if a helper is broken, the tests depending on it will fail
