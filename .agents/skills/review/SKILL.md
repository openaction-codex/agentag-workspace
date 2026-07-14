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

Accept an explicit review mode of `approve`, `comment`, or `request-changes`.
Default to `comment`. Ask the user to choose only when a Linear issue links to
multiple plausible PRs.

## Operating rules

- Write concise Mattermost updates in the user's language. When a specialist
  is involved, relay only concrete milestone notes.
- Clone missing repositories under `codebases/`. Preserve unrelated changes;
  use an isolated worktree when checkout would disturb them.

## Resolve context

1. For a Linear ID, read the full issue, comments, links, and attachments.
   Resolve its implementation PR and repository from those sources.
2. For a PR input, resolve the repository from the URL, explicit input, or
   current repository. Read the PR body and links to identify the Linear issue.
3. Read both Linear and PR context when linked. Treat later issue clarification
   as the expected behavior and note any disagreement with the PR description.

## Review workflow

1. Validate GitHub authentication and fetch the base and head revisions.
2. Inspect PR metadata, full diff, commits, changed files, existing reviews,
   inline comments, conversation, and required checks.
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
8. Submit the review with `gh pr review`. Default to `--comment`; use approval
   or request changes only when explicitly requested and appropriate. Add
   targeted inline comments when they make a fix easier to understand.
9. Return a concise Mattermost summary with the verdict, finding counts,
   validation performed, PR link, and any blocker. Do not paste a long review
   when the GitHub link is sufficient.

## Evidence commands

Adapt these commands to the resolved repository and use temporary files outside
the repository when practical:

```bash
gh pr view "$PR" --repo "$REPO" \
  --json number,title,body,url,isDraft,author,baseRefName,headRefName,headRefOid,changedFiles,additions,deletions,commits,labels,reviewDecision
gh pr diff "$PR" --repo "$REPO"
gh pr checks "$PR" --repo "$REPO"
gh api --paginate "repos/$REPO/pulls/$PR/comments?per_page=100"
gh api --paginate "repos/$REPO/pulls/$PR/reviews?per_page=100"
gh api --paginate "repos/$REPO/issues/$PR/comments?per_page=100"
```

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
