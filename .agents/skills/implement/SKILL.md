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
9. Commit with the issue ID, push the feature branch, and open a draft GitHub
   PR whose title contains the issue ID. Use only the exact PR body format
   below.
10. Monitor required CI and Coolify preview checks. Diagnose failures, fix
    in-scope problems, and push follow-up commits. Retrieve and verify the four
    preview URLs using the rules below.
11. When required checks pass and all four preview URLs are verified, mark the
    PR ready, link it to Linear, and post exactly one Linear comment using the
    format below.
12. Move the issue to `In review`. Return a concise Mattermost summary with
    issue and PR links, behavior delivered, tests run, CI state, preview state,
    and any follow-up.

## GitHub PR body

Write exactly these three top-level sections in this order. Add no preamble,
issue metadata, link list, test section, generated footer, or other text. Put
all technical and validation details inside the third section's code block.

````markdown
## Résumé fonctionnel

<En français non technique, résumer en quelques phrases l'objectif de l'issue
Linear et l'approche fonctionnelle effectivement mise en œuvre. Écrire pour le
client final, sans noms de classes, fichiers, commandes ou détails internes.>

## Parcours de test sur la prévisualisation

1. Dans l'application `<console|public|platform|mobilisation>`, utiliser les
   données de prévisualisation `<fixture ou jeu de données>`.
2. Accéder à `<navigation précise dans l'interface>`.
3. Effectuer `<interactions UI précises>`.
4. Vérifier `<résultat fonctionnel visible attendu>`.

<Ajouter uniquement les autres parcours nécessaires, avec pour chacun
l'application, la navigation, les interactions, les fixtures de
prévisualisation et le résultat attendu.>

## Agent continuation context

```markdown
### Implementation decisions and approach

- Decision: <decision and implementation details>
- Approach: <architecture, data flow, contracts, and relevant code anchors>
- Rationale: <why this approach was selected>

### Deviations

- <deviation from the Linear issue or specification, with rationale>

### Validation

- <test, formatter, or manual check run and its result>
- <relevant CI or preview state>

### Risks and continuation

- Risk: <remaining risk, limitation, or operational concern>
- Continue with: <specific context and next action for a future agent>
```
````

Copy the first two sections verbatim into the Linear comment. Keep their
content concise, non-technical, and in French. Make the preview workflow usable
by a human: name the app, navigation path, UI actions, preview fixture data,
and visible result. Inspect the available preview fixtures and name the exact
fixture or test record to use; never invent one or instruct the tester to use
production data.

Write the third section in English for future agents. Record every relevant
implementation decision, approach, rationale, technical detail, deviation,
validation result, risk, and continuation detail. Omit empty internal
subsections, but do not move technical content outside the raw Markdown code
block. Wrap every line inside that block to at most 80 characters, including
commands and code paths. Check the prepared body before publication; the
following command must print nothing:

```bash
awk '
  /^```markdown$/ { in_block=1; next }
  in_block && /^```$/ { in_block=0 }
  in_block && length($0) > 80 { print NR ":" length($0) }
' pr-body.md
```

## Coolify preview URLs

Retrieve URLs only from evidence tied to the current PR and head commit, such
as GitHub deployment environments, successful Coolify/CI check output, or a
Coolify bot comment on the PR. Match each URL to its explicitly named app.
Open or probe every URL and verify that it is a reachable preview for the
current PR. Never derive a hostname from another app, copy a production URL,
or guess a URL from naming conventions.

Require verified preview URLs for all four apps: `console`, `public`,
`platform`, and `mobilisation`. If any URL is missing, ambiguous, unreachable,
or not tied to the current PR, keep the PR in draft, keep Linear `In progress`,
do not post the Linear comment, and report the missing evidence in Mattermost.
Continue monitoring or fix the preview deployment; never claim completion with
placeholder or inferred URLs.

## Linear comment

Post exactly these three top-level sections in this order. Copy the first two
sections and their content verbatim from the PR. Add no technical summary,
issue metadata, CI details, status note, footer, or other commentary.

```markdown
## Résumé fonctionnel

<Copie exacte de la première section de la PR>

## Parcours de test sur la prévisualisation

<Copie exacte de la deuxième section de la PR>

## Prévisualisations Coolify

- Console : <URL de prévisualisation vérifiée>
- Public : <URL de prévisualisation vérifiée>
- Platform : <URL de prévisualisation vérifiée>
- Mobilisation : <URL de prévisualisation vérifiée>
```

## Quality check

Before handing off, verify that:

- the implementation satisfies the issue's latest accepted scope;
- every material specification requirement is implemented or explicitly
  explained;
- focused tests cover important success, edge, permission, and failure paths;
- the branch contains no unrelated edits or sensitive data;
- the PR body has only the three required sections and its raw Markdown block
  has no line longer than 80 characters;
- the Linear comment has only the two verbatim French sections and the four
  verified Coolify preview URLs;
- Linear, the PR, and the Mattermost summary agree on the actual result.
