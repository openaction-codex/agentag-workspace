---
name: implement
description: "Implement an OpenAction Linear issue end to end from Mattermost. Use when given a Linear issue ID and asked to build, fix, or deliver it: read the full issue and any technical specification, inspect or clone the relevant repository, implement and test the change, open a GitHub pull request, update Linear, and report the result."
---

# Implement a Linear Issue

Implement one Linear issue through a review-ready pull request. Use an existing
technical specification in the issue as the implementation workflow when one
is present.

## Inputs

Require one Linear issue ID, such as `OPE-123`. Ask only when the issue,
repository, or a product decision cannot be resolved unambiguously.

## Operating rules

- Write concise Mattermost updates in the user's language. When a specialist
  is involved, relay only concrete milestone notes.
- Clone missing repositories under `codebases/`. Default to
  `openaction-europe` only when the issue gives no stronger repository signal.
- Preserve unrelated changes and never push directly to `main`.

## Workflow

1. Read the issue's title, body, status, labels, links, attachments, and all
   comments. Resolve the relevant repository and any linked pull request.
2. Locate the latest technical specification in the issue body. When present,
   use its implementation context, design, impacts, edge cases, validation,
   scope boundaries, and decisions as issue-specific guidance. Let newer issue
   comments and the current code override stale details; disclose any material
   divergence.
3. When no specification exists, derive the smallest safe implementation from
   the issue and current code. Ask about ambiguity only when it changes product
   behavior or scope. You can use the `specify` skill as reference on how to 
   do the specification.
4. Move the issue to `In progress`.
5. Fetch the latest `main`, verify the worktree state, and create a branch from
   `origin/main`, normally `codex/<lowercase-issue-id>-<short-slug>`.
6. Inspect existing patterns and focused tests before editing. Implement the
   complete change, including migrations, permissions, translations,
   observability, or compatibility work when relevant.
7. Add or update focused tests. Run the tests and formatters required by the
   specification and affected repository. Never run the full PHP test suite;
   use individual classes or methods. Fix in-scope failures.
8. Review the diff for correctness, security, data safety, unintended scope,
   generated artifacts, and accidental secrets. Reconcile it with the issue
   and specification.
9. Commit with the issue ID, push the feature branch, and open a GitHub PR with
   the issue ID in its title and a concise technical summary plus validation
   results in its body.
10. Link the PR to Linear. Add a concise technical summary and a concise
    non-technical French customer-facing summary as an issue comment.
11. Monitor required CI checks. Diagnose failures, fix in-scope problems, and
    push follow-up commits. If an external or persistent failure remains,
    explain it and keep the PR in draft or the issue in progress rather than
    claiming review readiness.
12. Move the issue to `In review` when the implementation and required checks
    are ready. Return a concise Mattermost summary with issue and PR links,
    behavior delivered, tests run, CI state, and any follow-up.

## Quality check

Before handing off, verify that:

- the implementation satisfies the issue's latest accepted scope;
- every material specification requirement is implemented or explicitly
  explained;
- focused tests cover important success, edge, permission, and failure paths;
- the branch contains no unrelated edits or sensitive data;
- Linear, the PR, and the Mattermost summary agree on the actual result.
