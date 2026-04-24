---
name: update-boilerplate-prs
description: Batch-process generic-boilerplate update PRs (Renovate copier) across fohte org repositories. Validate, triage, resolve conflicts, and prepare PRs for human merge.
---

# Batch Processing generic-boilerplate Update PRs

Validate generic-boilerplate update PRs created by Renovate and resolve conflicts via `/delegate-claude` for PRs that need intervention. Final merge is always performed manually by the user -- never merge on their behalf.

## Merge policy (read before doing anything)

- **Never run `gh pr merge`** as part of this skill, including `--auto`. The user reviews and merges every PR manually.
- The only exception is `scripts/auto-merge-boilerplate-prs` in Step 4, which is a user-sanctioned helper for the narrowly-defined "version-only" case (pre-validated diff shape). Do not generalize this to any other path.
- For everything else -- including MERGE-READY PRs surfaced in Step 5 -- stop after validation and reporting. Do not enable auto-merge, do not approve, do not merge.
- This policy must also be passed down to every `/delegate-claude` prompt in Step 7.

## Overall Flow

1. **Understand changes**: Review what changed in generic-boilerplate itself
2. **Identify outdated repos**: Run `scripts/list-boilerplate-usage --outdated` to find targets
3. **Trigger PR creation for repos without PRs**: Check Renovate Dashboard checkboxes to bypass rate limits
4. **Auto-merge version-only PRs**: Run `scripts/auto-merge-boilerplate-prs` for trivial PRs (the only sanctioned auto-merge path)
5. **Validate remaining PRs**: Review diff, CI status for PRs with actual template changes
6. **Report findings**: Present MERGE-READY and NEEDS-INTERVENTION lists to the user. Do not merge; the user merges manually after review
7. **Delegate template application**: Delegate via `/delegate-claude` for NEEDS-INTERVENTION PRs. Each delegate fixes conflicts, pushes, waits for CI, addresses reviewer comments, then hands the PR back to the user for merge

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
- For each conflict, compare versions on both sides. If the `before updating` side has a newer version than the `after updating` side, flag it as a potential downgrade in the Step 6 report (the repo may have been updated independently by Renovate or other means)
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

## Step 6: Report findings to user

Evaluate each PR against these criteria:

- **MERGE-READY**: No conflict markers + CI pass + changes correctly propagated
- **NEEDS-INTERVENTION**: Conflict markers present, or propagation issues detected

Report results in a table and hand over to the user. **Do not merge MERGE-READY PRs** -- the user reviews and merges them manually. Proceed to Step 7 only for NEEDS-INTERVENTION PRs, and only after the user confirms delegation.

## Step 7: Delegate template application

Delegate PRs that need manual intervention via the `/delegate-claude` skill. The goal is to ensure the latest template is correctly applied to each repository -- conflict resolution is just one means to that end.

### Branch name (required)

The `<branch-name>` argument for `a wm new` **must be the PR's actual branch name**, so that commits are pushed to the existing PR branch. Never create a new branch name.

```bash
gh pr view <number> -R fohte/<repo> --json headRefName -q .headRefName
```

Use the fetched value directly as the branch name. The existing remote branch will be checked out automatically.

```bash
a wm new renovate/https-github.com-fohte-generic-boilerplate-0.x -R ~/ghq/github.com/fohte/<repo> --agent --label "..." --prompt "..."
```

**Do NOT invent a new branch name** like `renovate-foo-boilerplate`. **Do NOT add `--from`** -- the branch already exists on the remote.

### Delegation prompt

Include the following in the delegation prompt:

- generic-boilerplate changes (Step 1 results)
- Issues found during validation (conflict markers, incorrect parameter values, missing files, etc.)
- Repository-specific customizations to preserve (e.g., repo-specific dependencies, local settings)
- Context for resolution decisions (e.g., lefthook-config referencing itself remotely is inappropriate)

### Conflict resolution rule: do NOT blindly choose `after updating` (always include in prompt)

Copier conflict markers have two sides:

- `before updating`: the repository's current state, which may have been updated independently (e.g., by Renovate) to a newer version than the template
- `after updating`: the template's rendered result, which is NOT always the correct choice

For each conflict, compare the versions on both sides:

- If `before updating` has a newer version, keep it -- do not downgrade
- If `after updating` introduces structural changes (e.g., new `with:` inputs, format changes like SHA pinning), apply the structural change but preserve the newer version from `before updating`
- Example (version only): `before updating` has `actions/create-github-app-token@SHA-A # v3.1.0`, `after updating` has `actions/create-github-app-token@SHA-B # v3.0.0` -> keep `@SHA-A # v3.1.0`
- Example (structural + version): `before updating` has `actions/setup-node@v4`, `after updating` has `actions/setup-node@v3` with a new `with: { cache: 'pnpm' }` input -> result should be `actions/setup-node@v4` with `with: { cache: 'pnpm' }`

This rule must be explicitly included in every delegation prompt.

### copier update notes (always include in prompt)

The delegate may need to run `copier update --trust`. Always include these notes:

- `copier update` requires a clean working tree. Commit changes before running it
- `copier update` may fail with "Argument list too long" in repos with large `node_modules`. Temporarily move `node_modules` out (e.g., `mv node_modules /tmp/...`), run copier update, then restore. Commit first to avoid the dirty tree error
- If `copier update` fails mid-way, the working tree may be in a partial state. `git checkout -- .` to reset, fix the root cause, then retry
- After `copier update` succeeds, review the full diff carefully before committing. Do not commit partial/broken state

### Delegation goal

The latest generic-boilerplate template (v<latest>) is correctly applied to the repository and the PR is left in a state where the user can review and merge it. Specifically:

- All copier conflict markers are resolved
- Template parameters in `.copier-answers.yml` match the repo's actual usage (e.g., `use_storybook: true` if the repo uses Storybook)
- All expected template-generated files are present and correct
- Repository-specific customizations are preserved
- Syntax checks pass (e.g., `jq .` for JSON, appropriate tools for TOML/YAML)
- Commit and push (no new PR needed; push to the existing PR branch)
- **Follow the same post-push flow as `/create-pr`**: wait for CI to finish, wait for Gemini Code Assist review via `a ai review wait`, and address reviewer feedback via the `check-pr-review` skill (`a gh pr-review check`) until every unresolved thread is handled
- If CI fails, investigate the cause, fix, and re-push (same loop as `/create-pr`)
- **Do NOT merge or approve the PR.** Never run `gh pr merge` (including with `--auto` / `--admin`), do not enable auto-merge, and do not approve the PR (approval can trigger auto-merge in repos where it is wired up). The user merges manually after reviewing. End by reporting the PR URL and current state (CI green, review resolved) back to the caller

### Delegation prompt checklist

Every delegation prompt must explicitly state all of the following so the child session cannot shortcut the flow:

1. **Conflict resolution rule** (copy the "do NOT blindly choose `after updating`" section)
2. **copier update notes** (clean tree, node_modules workaround, partial-state reset)
3. **Post-push flow**: wait for CI, `a ai review wait`, `check-pr-review` for reviewer feedback, re-push and re-wait until clean
4. **Merge prohibition**: do not run `gh pr merge`, do not enable auto-merge, do not approve. Hand the PR back to the user for manual merge. State this in imperative form -- implicit hints are routinely ignored by child sessions
5. **Completion report format**: PR URL, CI status, review status, any follow-ups the user needs to be aware of
