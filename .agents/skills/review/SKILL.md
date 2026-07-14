---
name: review
description: "Review an OpenAction change from either a Linear issue ID or a GitHub pull request number or URL. Use when asked from Mattermost to review, analyze, or check an issue's implementation or PR: resolve the linked issue and repository, inspect the code and GitHub context, run focused validation when useful, publish actionable findings on GitHub, and return a concise Mattermost summary."
---

# Review an Issue or Pull Request

Review one implementation deeply, publish actionable findings on GitHub, and
summarize the result in Mattermost.

## Inputs

Accept one of:

- a Linear issue ID, such as `OPE-123`;
- a GitHub PR number, such as `#123`, optionally with `owner/repo`;
- a GitHub pull request URL.

Ask the user to choose only when a Linear issue links to multiple plausible
PRs. Derive the review submission mode from the verified findings; do not
accept a mode override.

## Operating rules

- Keep Mattermost updates concise and in the user's language; relay only
  concrete specialist milestones. Clone missing repositories under `codebases/`,
  preserve unrelated changes, and use an isolated worktree when needed. Use
  GitHub MCP for all GitHub reads and writes; if required operations are absent,
  stop and report them.

## Resolve context

1. For a Linear ID, read the full issue, comments, links, and attachments.
   Resolve its implementation PR and repository from those sources.
2. For a PR input, resolve the repository from the URL, explicit input, or
   current repository. Read the PR body and links to identify the Linear issue.
3. Read both Linear and PR context when linked. Treat later issue clarification
   as the expected behavior and note any disagreement with the PR description.

## Review workflow

1. Resolve the repository and pull request with the GitHub MCP pull-request
   read operation. Record the base revision and current head SHA.
2. Use GitHub MCP read operations to inspect PR metadata, the full diff,
   changed files, commits, reviews, inline threads, conversation, check runs,
   statuses, and deployments.
3. Inspect relevant code outside the diff to verify call sites, contracts,
   migrations, permissions, and established patterns.
4. Analyze the change with `references/review-criteria.md`. Prefer concrete
   product-impacting findings over stylistic commentary.
5. Run focused tests or static checks when they materially improve confidence.
   Do not run the full PHP suite.
6. Verify each finding against the head revision. Cite a precise path and line
   for every code finding and avoid duplicating an already resolved comment.
7. Draft the GitHub review using the format below. Use `Blocker`, `Important`,
   `Nit`, and `Question` consistently with the reference criteria.
8. Re-read the PR head SHA through GitHub MCP. If it changed, refresh the diff
   and revalidate every finding before submission.
9. Select `request-changes` when at least one verified finding is classified
   as `Blocker`. Select `comment` when there is no `Blocker`, including when
   there are only Important, Nit, or Question findings, or no findings. Never
   select approval.
10. Submit exactly one review with the GitHub MCP review-submission operation
    and the selected mode. Include targeted inline comments in that review
    when they make a fix easier to understand.
11. Return a concise Mattermost summary with the submitted mode, finding
    counts, validation performed, PR link, and any blocker. Do not paste a long
    review when the GitHub link is sufficient.

## GitHub MCP operations

Use the installed GitHub MCP tools whose schemas provide these operations:

- get a pull request with base/head revisions and metadata;
- list or retrieve changed files and the complete diff;
- list commits, reviews, review threads, and conversation comments;
- list check runs, statuses, and deployments for the PR head SHA;
- submit a pull request review, including inline comments and its event mode.

Follow each installed tool's schema rather than assuming parameter or enum
names. Paginate until all files, commits, and comments are retrieved. Do not
silently omit evidence when an operation is missing.

## Review format

Use this structure for the GitHub review body:

```markdown
## Summary
<1-3 lines describing the implementation and overall assessment>

## Findings
### Blocker
- [`path:line`] <problem, impact, and concrete remediation>

### Important
- [`path:line`] <problem, impact, and concrete remediation>

### Nit
- [`path:line`] <optional improvement>

## Questions
- <clarification needed to establish correctness>

## Positive notes
- <effective design, test, or clarity choice>
```

Skip empty severity and optional sections. When no actionable issue exists,
write `No actionable findings.` under `Findings`.

## Guardrails

- Never modify the implementation during a review unless the user separately
  asks for fixes.
- Do not expose secrets, personal data, private customer details, or raw
  internal logs in GitHub or Mattermost.
- Distinguish verified defects from questions and low-confidence concerns.
- Review the changed behavior, not the author; keep feedback direct and
  respectful.
- Confirm that the submitted mode is `request-changes` if and only if the
  review contains at least one `Blocker`; otherwise confirm `comment`.
