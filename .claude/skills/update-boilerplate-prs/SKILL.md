---
name: update-boilerplate-prs
description: Batch-process generic-boilerplate update PRs (boilerplate-update.yml / copier-update-action) across fohte org repositories. Validate, triage, resolve conflicts, and merge.
---

# Batch Processing generic-boilerplate Update PRs

Validate generic-boilerplate update PRs created by the `boilerplate-update.yml` workflow (via `fohte/copier-update-action`) and resolve conflicts via `/delegate-claude` for PRs that need intervention. MERGE-READY PRs are merged automatically once validated.

## Merge policy (read before doing anything)

- **MERGE-READY PRs are merged.** Once a PR is validated as MERGE-READY (no conflict markers + CI pass + changes correctly propagated), merge it with `gh pr merge --squash --auto`. No per-PR user confirmation is required.
- `scripts/auto-merge-boilerplate-prs` in Step 4 is the fast path for the version-only case: it batch-merges PRs whose diff shape is pre-validated (only `_commit` bumps), skipping the per-PR validation that Steps 5-6 perform.
- NEEDS-INTERVENTION PRs are merged only after their conflicts are resolved. When a `/delegate-claude` delegate finishes resolving conflicts, the delegate executes Step 7's "CI watch and merge protocol" (it cannot stop at scheduling `--auto` -- it must observe CI to completion and confirm `state == "MERGED"`).

## Overall Flow

1. **Understand changes**: Review what changed in generic-boilerplate itself
2. **Identify outdated repos**: Run `scripts/list-boilerplate-usage --outdated` to find targets
3. **Trigger boilerplate-update workflow runs**: Dispatch `boilerplate-update.yml` immediately instead of waiting for the weekly cron
4. **Auto-merge version-only PRs**: Run `scripts/auto-merge-boilerplate-prs` for trivial PRs left over after Step 3 (a fallback path; `boilerplate-update.yml` already auto-merges most of these itself)
5. **Validate remaining PRs**: Review diff, CI status for PRs with actual template changes
6. **Report and merge**: Merge MERGE-READY PRs; present the NEEDS-INTERVENTION list to the user
7. **Delegate template application**: Delegate via `/delegate-claude` for NEEDS-INTERVENTION PRs. Each delegate fixes conflicts, pushes, then executes the CI watch and merge protocol (Step 7) end to end until the PR reaches `state == "MERGED"`

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

The output shows each repository's current version, latest version, and whether an open update PR exists.

- `update PR: (none)` -> Step 3 will dispatch `boilerplate-update.yml` to create one
- `update PR: #<number> <url>` -> Step 3 will re-dispatch `boilerplate-update.yml`, which force-pushes the branch with the latest template state (updates the existing PR in place); proceed to Step 4 once `COMPLETED` is printed

## Step 3: Trigger boilerplate-update workflow runs

Every outdated repo already has `.github/workflows/boilerplate-update.yml` (calls `fohte/copier-update-action`), which normally runs on a weekly cron and creates or refreshes the update PR itself -- including auto-merging it when `copier-update-action` reports no unresolved conflicts. This step dispatches that workflow immediately instead of waiting for the next scheduled run.

```bash
# Dry-run first to verify targets
scripts/trigger-boilerplate-update-prs --dry-run

# Dispatch the workflow for all outdated repos, then wait for the runs to finish
scripts/trigger-boilerplate-update-prs

# Or target specific repos, or a specific template version
scripts/trigger-boilerplate-update-prs <repo1> <repo2>
scripts/trigger-boilerplate-update-prs --target-version v0.8.12
```

The script polls every 20 seconds (up to 5 minutes), printing `DISPATCHED <repo>: boilerplate-update.yml` immediately after dispatch and `COMPLETED <repo>: conclusion=<value> (<run url>)` once each run finishes (`conclusion` is GitHub's run conclusion, e.g. `success`, `failure`, `cancelled`; any value other than `success` is treated as a failure). Re-run `scripts/list-boilerplate-usage --outdated` afterward to see the resulting PRs.

## Step 4: Auto-merge version-only PRs

PRs where the only change is the `_commit` version bump in `.copier-answers.yml` can be merged automatically without manual review.

`boilerplate-update.yml` already schedules `gh pr merge --auto --squash` itself whenever `copier-update-action` reports no unresolved conflicts, so most version-only PRs from Step 3 are already auto-merging by the time you reach this step. This step is a fallback for PRs where that scheduling did not happen (e.g. the workflow run failed before reaching the merge step, or the PR predates this migration).

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
- For each conflict, compare versions on both sides. If the `before updating` side has a newer version than the `after updating` side, flag it as a potential downgrade in the Step 6 report (the repo may have been updated independently, e.g. merged manually or via an earlier workflow run)
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

## Step 6: Report and merge

Evaluate each PR against these criteria:

- **MERGE-READY**: No conflict markers + CI pass + changes correctly propagated
- **NEEDS-INTERVENTION**: Conflict markers present, or propagation issues detected

Report results in a table. **Merge MERGE-READY PRs** with `gh pr merge --squash --auto`. Proceed to Step 7 only for NEEDS-INTERVENTION PRs, and only after the user confirms delegation.

## Step 7: Delegate template application

Delegate PRs that need manual intervention via the `/delegate-claude` skill. The goal is to ensure the latest template is correctly applied to each repository -- conflict resolution is just one means to that end.

### Branch name (required)

The `<branch-name>` argument for `a wm new` **must be the PR's actual branch name**, so that commits are pushed to the existing PR branch. Never create a new branch name.

```bash
gh pr view <number> -R fohte/<repo> --json headRefName -q .headRefName
```

Use the fetched value directly as the branch name. The existing remote branch will be checked out automatically.

```bash
a wm new copier-update/v0.8.9 -R ~/ghq/github.com/fohte/<repo> --agent --label "..." --prompt "..."
```

**Do NOT invent a new branch name** like `copier-update-foo-boilerplate`. **Do NOT add `--from`** -- the branch already exists on the remote.

### Delegation prompt

Include the following in the delegation prompt:

- generic-boilerplate changes (Step 1 results)
- Issues found during validation (conflict markers, incorrect parameter values, missing files, etc.)
- Repository-specific customizations to preserve (e.g., repo-specific dependencies, local settings)
- Context for resolution decisions (e.g., lefthook-config referencing itself remotely is inappropriate)

### Conflict resolution rule: do NOT blindly choose `after updating` (always include in prompt)

Copier conflict markers have two sides:

- `before updating`: the repository's current state, which may have been updated independently (e.g., merged manually or via an earlier workflow run) to a newer version than the template
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

### CI watch and merge protocol (always include in prompt verbatim)

`gh pr merge --squash --auto` is a _reservation_ that fires only if CI eventually passes. Scheduling it and reporting "done" without observing CI is a violation -- if CI fails, the PR sits unmerged indefinitely and the delegator never finds out. Soft phrases like "wait for CI" are routinely ignored by child sessions, so this protocol must be copied into every delegation prompt verbatim and executed step by step:

1. **Watch every check to completion.** After pushing, run `gh pr checks <number> -R fohte/<repo> --watch --fail-fast=false` and wait until it exits. Then re-run `gh pr checks <number> -R fohte/<repo>` (without `--watch`) and read every row with your own eyes -- do not infer. Every row must be `pass` or `skipping` (path-filtered jobs and neutral conclusions are acceptable); any `pending` / `queued` / `in_progress` row means step 1 is not done yet; any `fail` row blocks merge
2. **On any failure, debug and re-push.** If any row is `fail`, run `gh run view <run-id> -R fohte/<repo> --log-failed` (find the failing run id in the `gh pr checks` output) to read the failure, fix the cause, commit, push, and return to step 1. Repeat until step 1 shows only `pass` / `skipping`
3. **Only then enable auto-merge.** Once step 1's non-watch output shows only `pass` / `skipping`, run `gh pr merge <number> -R fohte/<repo> --squash --auto`
4. **Confirm the PR is MERGED.** Run `gh pr view <number> -R fohte/<repo> --json state,mergedAt` and verify `state == "MERGED"`. If it is still `OPEN`, the merge has not happened -- wait and re-check, or investigate why auto-merge did not fire (branch protection, required reviews, mergeability). Do not report completion until `state == "MERGED"`

Reporting completion with only step 3 done (auto-merge scheduled but CI never observed and `MERGED` never confirmed) is a violation of this protocol.

### Delegation goal

The latest generic-boilerplate template (v<latest>) is correctly applied to the repository and the PR is merged. Specifically:

- All copier conflict markers are resolved
- Template parameters in `.copier-answers.yml` match the repo's actual usage (e.g., `use_storybook: true` if the repo uses Storybook)
- All expected template-generated files are present and correct
- Repository-specific customizations are preserved
- Syntax checks pass (e.g., `jq .` for JSON, appropriate tools for TOML/YAML)
- Commit and push (no new PR needed; push to the existing PR branch)
- Execute the **CI watch and merge protocol** above end to end -- the PR must reach `state == "MERGED"` before reporting completion

### Delegation prompt checklist

Every delegation prompt must explicitly state all of the following so the child session cannot shortcut the flow. Items marked _verbatim_ must be copied as full sections (not paraphrased) -- abbreviated or implicit versions are routinely ignored by child sessions:

1. **Conflict resolution rule** -- copy the "do NOT blindly choose `after updating`" section _verbatim_
2. **copier update notes** -- copy the "copier update notes" section _verbatim_ (clean tree, node_modules workaround, partial-state reset)
3. **CI watch and merge protocol** -- copy the "CI watch and merge protocol" section _verbatim_, including the four numbered steps and the "violation" sentence. Do not summarize as "wait for CI and merge"; the explicit `gh pr checks --watch` / `gh run view --log-failed` / `gh pr view --json state` commands and the all-SUCCESS / `MERGED` confirmation requirements must appear in the prompt
4. **Completion report format**: PR URL, the final `state` from `gh pr view --json state` (must be `MERGED`), a summary of conflicts resolved and CI failures fixed, and any follow-ups the user needs to be aware of
