---
name: rebase-pr
description: "Rebuild an OpenAction GitHub pull request on the latest main by cherry-picking its commits onto a clean branch, resolving conflicts, validating the result against the PR and any linked Linear issue, and safely updating the original PR branch. Use when asked to rebase, refresh, cleanly replay, or repair a conflicting or outdated PR branch."
---

# Rebase a Pull Request

Reapply one pull request onto the latest `main` with cherry-picks. Preserve the
intended behavior, not merely the old textual diff.

## Inputs

Accept one pull request as:

- a GitHub pull request URL;
- `owner/repository#number`;
- a PR number when the repository is unambiguous from the current checkout.

Ask only when the repository or PR cannot be resolved unambiguously. Require
the PR to target `main`; stop for any other base branch.

## Operating rules

- Follow the global testing, Git, and CI policy in `~/.codex/AGENTS.md` and the
  workspace policy in the parent `AGENTS.md`. They are authoritative for
  focused local validation, every push, CI timing, and failed-job log access.
- Follow the repository's `AGENTS.md` and local contribution instructions.
- Run from a checkout of the PR base repository. Preserve unrelated local
  changes and use an isolated worktree when the current checkout is not clean.
- Use the GitHub and Linear access available in the local environment. Require
  enough access to read the complete PR and any linked issue before rewriting
  history; stop and report missing context that prevents safe validation.
- Re-read the PR head SHA immediately before the final push. Never overwrite a
  head that changed during the operation.
- Under the global no-full-suite rule, select the smallest relevant test cases
  and targeted checks needed to prove that conflicted and replayed code was
  integrated correctly.
- Treat the rebase request as authorization to force-push the original PR
  branch with an exact lease after all safety checks pass. Do not request
  additional confirmation for that `--force-with-lease` push.

## Resolve intent

1. Read the complete PR: title, body, base and head repositories, base and head
   branches, head SHA, commits in oldest-to-newest order, full diff, changed
   files, conversation, reviews, and checks.
2. Resolve any Linear issue from the PR title, body, branch, or links. Read the
   full issue, comments, links, and attachments when access is available.
   Treat newer issue clarification as authoritative when it differs from an
   older PR body. If the issue cannot be read, stop only when the missing
   details prevent reliable validation of the intended behavior.
3. Record a short behavior checklist before rewriting: expected user-visible
   behavior, important technical contracts, tests, migrations, and explicit
   out-of-scope work.
4. If no Linear issue is linked, derive intent from the PR discussion, diff,
   tests, and surrounding code. Stop if a material product decision remains
   ambiguous.

## Prepare safely

1. Validate the base repository and the writable head repository instead of
   assuming both are `origin`. Fork-based PRs must be pushed to their actual
   head repository.
2. Fetch and prune the base `main` and the exact PR head. Record:
   `LATEST_MAIN_SHA`, `ORIGINAL_HEAD_SHA`, and `HEAD_BRANCH`.
3. Verify the fetched head equals the head SHA reported by the remote PR.
4. Create a local backup ref at the exact original head and push the same ref
   to the head repository before rewriting anything:
   `backup/<head-branch>-before-rebase-<timestamp>`.
5. Verify the remote backup resolves to `ORIGINAL_HEAD_SHA`.
6. Create an isolated clean branch from `LATEST_MAIN_SHA`, named for example
   `rebase-pr-<number>`.

Do not reset a user's existing checkout or reuse a branch with unrelated work.

## Reapply commits

1. Use the remote PR commit list as the authoritative replay candidates.
   Inspect each commit and classify it as kept, superseded, empty, or requiring
   manual integration.
2. Cherry-pick kept commits oldest to newest. Do not use `git rebase`; the goal
   is a deliberate clean replay.
3. Do not blindly cherry-pick merge commits. Inspect whether they contain
   unique PR behavior. Flatten that behavior into the clean history only when
   its parent choice and intended patch are clear; otherwise stop and ask.
4. When a cherry-pick becomes empty because `main` already contains the exact
   behavior, skip it and record the specific replacement on `main`.
5. Preserve meaningful commit boundaries where practical. Squash or split
   only when conflict resolution makes the original boundary misleading, and
   document the change.

## Resolve conflicts

For every conflict:

- preserve the latest `main` behavior outside the PR scope;
- preserve the PR and Linear behavior inside the PR scope;
- integrate both sides when upstream refactoring changed the implementation
  path but not the requested behavior;
- inspect call sites, tests, migrations, configuration, templates, and public
  contracts before deciding;
- avoid opportunistic refactors, formatting churn, and unrelated fixes;
- never choose `ours` or `theirs` wholesale without verifying the resulting
  behavior;
- stop and ask when the PR intent and current `main` cannot both be preserved
  confidently.

Record every conflicted file and the reason for its resolution.

## Verify before push

1. Confirm the clean branch is based on the recorded latest `main` SHA.
2. Compare the original PR patch and commit series with the clean result. Use
   `git range-diff` when useful, while allowing implementation differences that
   are required by current `main`.
3. Review the complete diff against `main`. Confirm every changed file maps to
   the behavior checklist and no conflict marker or accidental artifact
   remains.
4. Verify that all PR title/body claims and all applicable Linear acceptance
   criteria remain true. Document intentional differences and superseded
   commits.
5. Under the global testing policy, run only focused test cases that exercise
   the affected behavior, especially every conflicted path and any contract
   changed by conflict resolution. Run targeted formatters or static checks
   for touched files when useful; rely on required CI for broader coverage.
6. Re-read the remote PR and confirm its head SHA is still
   `ORIGINAL_HEAD_SHA`. If it changed, stop, fetch the new head, and restart
   the analysis rather than overwriting it.

## Update the PR branch

After validation, present the intended push, backup ref, kept/dropped commits,
conflict decisions, and test results, then:

1. Force-push the clean branch to the original head branch with an exact lease:

   ```bash
   git push \
     --force-with-lease=refs/heads/<head>:<original-head-sha> \
     <head-remote> <clean-branch>:refs/heads/<head>
   ```

2. Re-read the remote PR head SHA, diff, files, and checks.
3. Confirm the PR still targets `main`, the remote backup is recoverable, and
   the published diff matches the validated local result.
4. Monitor all required checks through a terminal result using the global CI
   timing and bounded GitHub MCP log policy. If a check fails, fix failures
   caused by the replay or conflict resolution, run the narrowest local
   regression test covering the fix, push with the same safety checks, and
   restart the global monitoring sequence. Repeat until required CI passes.
   For an unrelated infrastructure, flaky, or upstream failure that cannot be
   fixed safely in PR scope, retry when appropriate and report the precise
   blocker without claiming the PR is ready.

## Output

Return a concise summary containing:

- PR and head branch;
- old head, latest main, and new head SHAs;
- local and remote backup ref;
- commits kept, changed, skipped, or dropped with reasons;
- conflict files and resolution decisions;
- tests and verification result;
- CI failures diagnosed and fixes applied;
- push and final post-push PR/check status, or the precise blocker.

## Safety bar

- Never rewrite without a verified local and remote backup.
- Never force-push without an exact lease.
- Never overwrite a PR head that moved after analysis.
- Never drop behavior solely because a cherry-pick is difficult.
- Never claim success until the remote PR state matches the validated result.
