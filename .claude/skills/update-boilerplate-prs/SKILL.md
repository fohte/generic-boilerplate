---
name: update-boilerplate-prs
description: Batch-process generic-boilerplate update PRs (Renovate copier) across fohte org repositories. Validate, triage, resolve conflicts, and merge boilerplate update PRs.
---

# Batch Processing generic-boilerplate Update PRs

Validate generic-boilerplate update PRs created by Renovate, merge those that are ready, and resolve conflicts via `/delegate-claude` for the rest.

## Overall Flow

1. **Understand changes**: Review what changed in generic-boilerplate itself
2. **Identify outdated repos**: Run `scripts/list-boilerplate-usage --outdated` to find targets
3. **Trigger PR creation for repos without PRs**: Check Renovate Dashboard checkboxes to bypass rate limits
4. **Auto-merge version-only PRs**: Run `scripts/auto-merge-boilerplate-prs` for trivial PRs
5. **Validate remaining PRs**: Review diff, CI status for PRs with actual template changes
6. **Report merge decisions**: Present findings to the user for approval
7. **Resolve conflicts**: Delegate conflict resolution via `/delegate-claude`
8. **Merge after CI pass**: Confirm CI passes, then merge

## Step 1: Understand generic-boilerplate changes

Identify the source and target versions for each PR, then review the template diff.

```bash
# Update local clone
ghq get -u fohte/generic-boilerplate

# Review changes (read versions from PRs)
cd ~/ghq/github.com/fohte/generic-boilerplate
git log v<from>..v<to> --oneline
git diff v<from>..v<to> --stat
git diff v<from>..v<to>
```

Key areas to review:

- Tool version changes in `.mise.toml`
- Dependency changes in `package.json` (watch for breaking changes)
- CI workflow changes (action versions, workflow structure)
- New file additions (e.g., `scripts/bootstrap`)
- **Distinguish template-distributed files from repo-internal files** (e.g., `.gitattributes` is repo-internal and not distributed via copier)

## Step 2: Identify outdated repositories

```bash
scripts/list-boilerplate-usage --outdated
```

The output shows each repository's current version, latest version, and whether a Renovate PR exists.

- `renovate PR: #<number> <url>` present -> proceed to Step 4
- `renovate PR: (none)` -> proceed to Step 3 to trigger PR creation

## Step 3: Trigger PR creation from Renovate Dashboard

Repositories without a Renovate PR may be blocked by Renovate's rate limit (max concurrent PRs). Use the trigger script to check the Renovate Dependency Dashboard checkbox in each repository.

```bash
# Dry-run first to verify targets
scripts/trigger-renovate-boilerplate-prs --dry-run

# Update Dashboard checkboxes and wait for PRs to be created (all repos)
scripts/trigger-renovate-boilerplate-prs

# Or target specific repos
scripts/trigger-renovate-boilerplate-prs <repo1> <repo2>
```

The script updates all checkboxes, then polls every 30 seconds (up to 5 minutes) until Renovate creates the PRs, printing each PR URL as it appears.

## Step 4: Auto-merge version-only PRs

PRs where the only change is the `_commit` version bump in `.copier-answers.yml` can be merged automatically without manual review.

The script checks that the only diff lines are `_commit` version changes. When new template parameters are introduced (e.g., `use_storybook`), copier adds them to `.copier-answers.yml` with default values for repos that match the parameter's `when` condition. These PRs have additional diff lines beyond `_commit`, so the script automatically skips them -- they require manual validation in Step 5b.

Parameters with a `when` condition that evaluates to false for a given repo are not written to `.copier-answers.yml` at all, so those repos remain version-only and are safe to auto-merge.

```bash
# Dry-run first to verify
scripts/auto-merge-boilerplate-prs --dry-run

# Merge (enables auto-merge via --squash --auto, all repos)
scripts/auto-merge-boilerplate-prs

# Or target specific repos
scripts/auto-merge-boilerplate-prs <repo1> <repo2>
```

After this step, only PRs with actual template changes remain for manual validation.

## Step 5: Validate remaining PRs

Check the following in parallel for each PR (use subagents):

### 5a. Review the diff

```bash
gh pr diff <number> -R fohte/<repo>
```

- Check for copier conflict markers (`<<<<<<< before updating`, `=======`, `>>>>>>> after updating`)
- Verify that Step 1 changes propagated correctly
  - Each repository's template configuration (copier-answers.yml settings) determines which changes apply. Judge "expected changes" vs "not applicable" based on the configuration
  - Ensure repository-specific customizations (non-template changes) are not broken

### 5b. Verify new template parameters match actual repo usage

When a new template parameter is introduced (e.g., `use_storybook`), copier sets it to the default value. The default may not match the repo's actual usage. Check the actual repo contents to verify.

For example, if the template adds `use_storybook: false` by default but the repo actually uses Storybook (has `@storybook/*` in `package.json`), the parameter must be corrected to `true` so the corresponding template files are generated.

Do not trust the copier-answers values blindly -- always cross-check against what the repo actually uses.

### 5c. Check CI status

```bash
gh pr view <number> -R fohte/<repo> \
  --json mergeable,mergeStateStatus,statusCheckRollup
```

If CI is failing, review logs to identify the cause.

## Step 6: Report merge decisions to user

Evaluate each PR against these criteria:

- **Merge-ready**: No conflict markers + CI pass + changes correctly propagated
- **Not merge-ready**: Conflict markers present, or propagation issues detected

Report results in table format and obtain user approval. **Never finalize merge decisions independently. Always confirm with the user.**

## Step 7: Delegate template application

Delegate PRs that need manual intervention via the `/delegate-claude` skill. The goal is to ensure the latest template is correctly applied to each repository -- conflict resolution is just one means to that end.

### Fetch branch name (required)

The branch name passed to `/delegate-claude` **must be fetched from the PR**. Never guess.

```bash
gh pr view <number> -R fohte/<repo> --json headRefName -q .headRefName
```

Use the fetched value directly as the `<branch-name>` for `a wm new`.

### Delegation prompt

Include the following in the delegation prompt:

- generic-boilerplate changes (Step 1 results)
- Issues found during validation (conflict markers, incorrect parameter values, missing files, etc.)
- Repository-specific customizations to preserve (e.g., repo-specific dependencies, local settings)
- Context for resolution decisions (e.g., lefthook-config referencing itself remotely is inappropriate)

Delegation goal: the latest generic-boilerplate template (v<latest>) is correctly applied to the repository. Specifically:

- All copier conflict markers are resolved
- Template parameters in `.copier-answers.yml` match the repo's actual usage (e.g., `use_storybook: true` if the repo uses Storybook)
- All expected template-generated files are present and correct
- Repository-specific customizations are preserved
- Syntax checks pass (e.g., `jq .` for JSON, appropriate tools for TOML/YAML)
- Commit and push (no new PR needed; push to the existing PR branch)
- Wait for CI to complete after pushing and verify all checks pass
- If CI fails, investigate the cause, fix, and re-push
- Report to the user once CI passes (do not merge)
