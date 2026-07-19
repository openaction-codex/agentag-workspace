---
name: sync-fork
description: "Synchronize the main branch of one explicitly allowed OpenAction fork—openaction-ecologistes, openaction-placepublique, or openaction-lapres—with the latest citipo/openaction-europe main while preserving fork-specific behavior. Use when asked to update, refresh, replay, or synchronize one of these three forks with its Europe upstream."
---

# Synchronize an OpenAction Fork

Rebuild an allowed fork's `main` from the latest
`citipo/openaction-europe:main`, then reapply and verify fork-specific commits.

## Inputs and allowlist

Accept a repository name, `owner/repository`, or GitHub repository URL. Allow
only these exact repositories:

- `citipo/openaction-ecologistes`;
- `citipo/openaction-placepublique`;
- `citipo/openaction-lapres`.

Require `citipo/openaction-europe` as the exact upstream repository and `main`
as both branches. Reject every other repository, owner, upstream, or branch;
do not generalize this workflow.

## Operating rules

- Follow the global testing, Git, and CI policy in `~/.codex/AGENTS.md` and the
  workspace policy in the parent `AGENTS.md`. They are authoritative for
  focused local validation, every push, CI timing, and failed-job log access.
- Follow the repository's `AGENTS.md` and local contribution instructions.
- Run from a checkout with remotes for both the selected fork and Europe.
  Preserve unrelated local changes and use an isolated worktree when the
  current checkout is not clean.
- Use the GitHub and Linear access available in the local environment. Require
  enough context to classify fork-specific commits safely; stop and report
  missing context that prevents reliable validation.
- Default to cherry-picking fork-only commits onto upstream `main`. Use rebase
  only when the entire fork-only series is linear, cohesive, and every replay
  is demonstrably mechanical; explain the exception before using it.
- Under the global no-full-suite rule, select the smallest relevant test cases
  and targeted checks needed to prove that conflicted and replayed code was
  integrated correctly.
- Treat the fork synchronization request as authorization to push the allowed
  fork's `main` after all safety checks pass. Do not request additional
  confirmation for the leased push.

## Validate repository identity

1. Resolve the requested repository from its Git remote URL and confirm it
   exactly matches the allowlist.
2. Inspect local remotes rather than trusting their names. Configure or select
   one remote for the allowed fork and one for
   `citipo/openaction-europe`; verify their fetch and push URLs.
3. Fetch and prune both repositories. Record `ORIGINAL_FORK_SHA` from the
   remote fork `main` and `UPSTREAM_SHA` from the remote Europe `main`.
4. Verify both remote branch tips independently, for example with
   `git ls-remote`, and require exact agreement with the fetched SHAs. Stop on
   missing branches, identity mismatch, or concurrent movement.

## Discover fork-specific behavior

1. Find the merge base and inspect the complete fork-only history. Use both
   reachability and patch equivalence (`git cherry`) so that already-upstreamed
   patches are not replayed under different SHAs.
2. Treat `git rev-list upstream/main..fork/main` as candidates, not automatic
   proof that every commit is a customization. Inspect merge commits and
   periodic upstream sync commits separately.
3. For each candidate, inspect its diff and associated PR or issue context when
   available, including later comments that clarify expected behavior. Stop
   when unavailable context makes the commit's intent ambiguous.
4. Build a behavior checklist for the fork: custom features, branding,
   configuration, integrations, migrations, templates, and tests that must
   remain after synchronization.
5. Classify every candidate as:
   - fork-specific and to reapply;
   - already equivalent in upstream and safe to omit;
   - obsolete because a cited upstream change fully replaces it;
   - ambiguous and requiring user validation.

Do not proceed while an in-scope commit's intent remains ambiguous.

## Back up the fork

Before rebuilding history:

1. Create a local backup ref at exactly `ORIGINAL_FORK_SHA`:
   `backup/main-before-europe-sync-<timestamp>`.
2. Push the same backup ref to the allowed fork.
3. Verify locally and remotely that the backup resolves to
   `ORIGINAL_FORK_SHA`.

Never update fork `main` without this recoverable local and remote backup.

## Rebuild from Europe

1. Create an isolated sync branch directly from `UPSTREAM_SHA`.
2. Reapply confirmed fork-specific commits oldest to newest, normally with
   cherry-pick.
3. Do not blindly replay merge commits. Flatten only their unique custom
   behavior when its intent is fully understood.
4. Skip a commit only when the exact upstream replacement has been identified
   and no fork behavior is lost. Record its SHA, original intent, replacement,
   and rationale.
5. Preserve meaningful commit boundaries. Avoid unrelated cleanup while
   rebuilding the fork.

## Conflict policy

Resolve a conflict without asking only when the result is obvious and
mechanical, such as equivalent edits, a straightforward rename, formatting, or
context movement with no runtime effect. In every resolution:

- preserve current Europe behavior and fork-specific behavior together when
  both remain required;
- inspect call sites, conditionals, data mapping, configuration, migrations,
  templates, translations, tests, and public contracts before continuing;
- never select one side wholesale unless the other side is provably preserved
  elsewhere;
- never guess about business logic or client-specific requirements;
- stop and ask for validation on any functional conflict or uncertain intent.

Record every conflicted file and why the resolution preserves both sides.

## Verify before pushing main

1. Confirm the sync branch starts at the recorded `UPSTREAM_SHA` and contains
   only the classified fork-specific series above it.
2. Compare the original fork behavior with the rebuilt result. Use
   `git range-diff`, patch equivalence, and targeted code inspection where
   useful; do not rely on commit counts alone.
3. Review the complete diff against Europe `main`. Map each changed file to the
   fork behavior checklist and remove accidental drift or conflict artifacts.
4. Verify all applicable fork PR and Linear acceptance criteria as well as the
   relevant upstream behavior.
5. Under the global testing policy, run only focused test cases that exercise
   affected fork behavior, relevant upstream behavior, every conflicted path,
   and contracts changed by conflict resolution. Run targeted formatters or
   static checks for touched files when useful; rely on required CI for broader
   coverage.
6. Re-read both remote `main` tips independently. Require upstream to still
   equal `UPSTREAM_SHA` and the fork to still equal `ORIGINAL_FORK_SHA`. If
   either moved, stop and rebuild from the new state.

Present the strategy, backup, replay decisions, conflicts, tests, and exact old
and new SHAs before continuing.

## Update fork main

Update the allowed fork with an exact lease:

```bash
git push \
  --force-with-lease=refs/heads/main:<original-fork-sha> \
  <fork-remote> <sync-branch>:refs/heads/main
```

Then:

1. Fetch the fork and verify its remote `main` equals the validated sync head.
2. Verify the backup ref remains recoverable.
3. Re-read the remote branch and required CI checks.
4. Monitor all required checks through a terminal result using the global CI
   timing and bounded GitHub MCP log policy. If a check fails, fix failures
   caused by the replay, conflict resolution, or fork integration, run the
   narrowest local regression test covering the fix, update fork `main` with
   the same backup and exact-lease safety checks, and restart the global
   monitoring sequence. Repeat until required CI passes. For an unrelated
   infrastructure, flaky, or upstream failure that cannot be fixed safely in
   fork scope, retry when appropriate and report the precise blocker without
   claiming the synchronization succeeded.

## Output

Return a concise summary containing:

- allowed fork and upstream identities;
- strategy and reason;
- old fork, upstream, and new fork SHAs;
- local and remote backup ref;
- commits reapplied, changed, skipped, or dropped with reasons;
- conflicts and resolution decisions;
- tests and behavior verification;
- CI failures diagnosed and fixes applied;
- push and final post-push check status, or the precise blocker.

## Safety bar

- Never operate outside the three-repository allowlist.
- Never sync from an upstream other than `citipo/openaction-europe:main`.
- Never push `main` without a verified remote backup and an exact lease.
- Never discard custom behavior because upstream changed the same files.
- Never continue an ambiguous functional conflict.
- Never claim completion until remote `main` and required checks are verified.
