---
name: prepare-linear-spec
description: Prepare a technical specification for one or more Linear issues by ID. Use when asked to analyze Linear issues (title, description, comments) plus the repository codebase, then append an implementation-ready spec to each issue body in a Markdown code block and move each issue to "Spec to review".
---

# Prepare Linear Spec

Use this skill to produce an implementation-ready technical specification from
one or more Linear issues, then persist it in Linear.

## Inputs

Require:
- One or more Linear issue IDs (for example `OPE-123` or
  `OPE-123,OPE-456`)

Assume the current repository is the one that must be analyzed.

## Workflow

1. Checkout `main`.
2. For each issue ID, read the issue title, description, and all comments.
3. Analyze the codebase to identify existing patterns and relevant files.
4. For each issue ID, write a concise technical specification using the exact
   template below.
5. Keep each specification in English.
6. Keep every specification line at 80 chars max for Linear readability.
7. For each issue ID, append the specification to the end of the issue body,
   wrapped in a Markdown code block so that it's easy to copy/paste.
8. Do not post the specification as a comment.
9. Move each issue to `Spec to review`.

## Linear update requirements

When updating issue bodies:
- Preserve the existing content.
- Append the generated specification at the end of each issue body.
- Wrap the full specification in a fenced Markdown code block.

## Specification template

Use this exact template without changing section names or order:

```markdown
# Linear issue

ID: <current issue ID, like OPE-XXX>
Original customer title: <issue original title>

# Goal

<the general goal of the task, in 2-3 sentences>

# Technical approach

<A concise list of rules, technical approaches and constraints to take into
account, including pitfalls to avoid. Don't go in details, let the
implementation LLM decide the best way to do things. You can indicate code
locations of interesting things to look at for context.>

# REQUIRED process

* Change status of the Linear issue to "In progress"
* Fetch latest changes on main
* Create a new branch based on main
* Implement changes, including adding/updating tests where it's useful
* Ensure added/updated PHP and TS tests pass (run them individually with
  filters, fix if needed)
* NEVER run the full PHP test suite, it's too long, focus on individual tests
  classes/methods (you can do it for TSX tests, they are much faster)
* Run phpcsfixer in console and public
* Run yarn prettier in console/assets/modern and console/assets/legacy
* Commit, push
* Open a PR with the issue ID in title and with a short technical summary that
  explain the main technical changes for archiving purposes using the "gh" CLI
  tool.
* End the PR description with these exact footer lines:
  Agent shell prompt: <shell prompt, like root@dev-agent-1>
  Codex session ID: <the current Codex session ID>
  Resume command: `<full Codex CLI resume command, including
  --dangerously-bypass-approvals-and-sandbox and the session ID>`
* Check the CI every minute until all runners are successful. If it fails,
  analyse the runners concerned, fix, commit and push again.
* Link the GitHub PR to the Linear issue
* Add a comment on the Linear issue with:
	* a technical short summary that explain the main technical changes for
	  archiving purposes
	* a non-tech short summary in French of what was done, with enough details to
	  help to original customer understand the way it works and what it achieves,
	  without getting too technical
* Change status of the Linear issue to "In review"

Always commit, push, open a PR and update Linear even if the tests end up
failing after several trials.
```

## Quality bar

Before appending to Linear, verify for each issue:
- The spec is concrete enough for an implementation LLM.
- The scope matches the issue request and discussion.
- The template structure is unchanged.
- Line wrapping respects the 80-char maximum.
