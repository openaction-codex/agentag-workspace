---
name: specify-issue
description: Prepare and save an implementation-ready technical specification for one or more Linear issues. Use when asked from Mattermost to specify, scope, or technically analyze Linear issue IDs, including reading issue discussions and the relevant OpenAction codebase, updating the issue body, and moving it to "Spec to review".
---

# Specify Linear Issues for Implementation

Turn Linear issues into implementation-ready specifications and save them in
Linear.

## Inputs

Require one or more Linear issue IDs, such as `OPE-123` or
`OPE-123,OPE-456`. Ask only when an issue or repository cannot be resolved
unambiguously.

## Operating rules

- Keep Mattermost updates concise and in the user's language; relay only
  concrete specialist milestones. Clone missing repositories under `codebases/`
  (default: `openaction-europe`), preserve unrelated changes, and never push
  directly to `main`. Use GitHub MCP for all GitHub reads and writes; if a
  required operation is unavailable, stop and report it.

## Workflow

1. Read each issue's title, body, status, labels, links, attachments, and all
   comments. Treat later clarifications as authoritative.
2. Move the issue to `Spec in progress`.
3. Resolve the relevant repository from issue context and links. Fetch the
   latest `main` without discarding local work.
4. Inspect the implementation on `origin/main`, including adjacent behavior,
   tests, migrations, configuration, and established conventions.
5. Extract only implementation-relevant facts and decisions that are not
   already clear from the issue: current code paths, ownership boundaries,
   contracts, constraints, risks, edge cases, and focused validation. Ask the
   user only when a decision materially changes the scope or product behavior.
6. Draft one concise English specification per issue with the template below.
   Complement the issue; do not repeat its title, problem statement, requested
   behavior, acceptance criteria, customer context, or discussion. Keep lines
   near 80 characters when practical.
7. Re-read the issue and relevant code to verify every file reference and
   technical claim.
8. Preserve the existing issue body. Replace an existing generated
   specification for that issue; otherwise append the new one in a fenced
   Markdown block. Do not post the specification as a comment.
9. Move the issue to `Human: Spec to review` only after its body update succeeds.
10. Report a concise Mattermost summary with issue links, repository, important
    decisions, and any unresolved question.

## Specification template

Use the verified `origin/main` commit as the baseline. Keep `Implementation
context`, `Implementation design`, and `Validation`. Include the other sections
only when they add concrete implementation information; do not emit empty
headings or generic boilerplate.

```markdown
# Implementation context

Repository: <owner/repository>

* `<path>` — `<symbol, module, route, schema, or test>`: <verified current
  behavior, dependency, convention, or invariant relevant to this change>
* <Describe the current execution/data flow only as needed to explain the
  implementation design.>

# Implementation design

* `<component or layer>`: <intended change and why it fits the existing
  architecture>
* <Describe required data flow, state transitions, contracts, and invariants.
  Name likely files or symbols when verified, without prescribing incidental
  low-level edits.>

# Impacts and constraints

* <Describe affected API/events, persistence, migrations, permissions,
  security/privacy, performance, observability, compatibility, deployment, or
  rollback constraints. Include only relevant items.>

# Edge cases

* <State a concrete boundary, failure mode, concurrency/idempotency case, or
  legacy-data condition and the expected implementation behavior.>

# Validation

* `<test file or suite>`: <specific scenario and expected assertion to add or
  update>
* `<focused command>`: <what it validates; include only commands verified for
  this repository>
* <Mention Coolify preview validation only for `citipo/openaction-europe`.
  Other projects must not depend on preview URLs.>

# Scope and open decisions

* Out of scope: <adjacent change that should deliberately remain untouched>
* Decision: <non-obvious technical choice and rationale>
* Open question: <unresolved implementation uncertainty, impact, and who or
  what can resolve it>
```

Do not repeat the generic branch, formatting, PR, CI, or Linear lifecycle in
the generated specification. The `implement-issue` skill owns that workflow and
uses this specification for issue-specific technical guidance.

## Quality check

Before updating Linear, verify that the specification:

- matches the issue and latest discussion and is grounded in the current
  codebase, with concrete anchors and scenario-level tests;
- adds implementation guidance rather than paraphrasing the issue, separating
  verified behavior, proposed design, and open questions;
- covers relevant contracts, data, security, compatibility, edge cases, and
  scope without boilerplate;
- contains no sensitive or irrelevant details and is actionable without
  prescribing incidental edits or duplicating the generic workflow.
