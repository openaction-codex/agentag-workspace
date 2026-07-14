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

- Keep Mattermost updates concise and in the user's language; relay only
  concrete specialist milestones. Clone missing repositories under `codebases/`
  (default: `openaction-europe`), preserve unrelated changes, and never push
  directly to `main`. Use GitHub MCP for all GitHub reads and writes; if a
  required operation is unavailable, stop and report it.

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
   PR through the GitHub MCP pull-request creation operation. Include the issue
   ID in its title and use only the exact PR body format below.
10. Monitor required CI and Coolify preview checks through GitHub MCP check,
    status, deployment, and PR-comment read operations. Diagnose failures, fix
    in-scope problems, and push follow-up commits. Retrieve and verify the four
    preview URLs using the rules below.
11. When required checks pass and all four preview URLs are verified, use the
    GitHub MCP pull-request update operation to mark the PR ready. Link the PR
    and post exactly one Linear comment through Linear tools using the format
    below.
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

Read the Coolify bot comment on the current PR and use only URLs explicitly
listed there for that PR and head commit. Match each URL to its named app and
verify that it is reachable. Never derive, copy, or guess a URL.

Require verified URLs for `console`, `public`, `platform`, and `mobilisation`.
If any is missing, ambiguous, unreachable, or not tied to the PR, keep the PR
in draft and Linear `In progress`, do not post the Linear comment, and report
the missing evidence. Never claim completion with incomplete or inferred URLs.

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

- the implementation and specification satisfy the latest accepted scope;
- focused tests cover important success, edge, permission, and failure paths;
- the branch has no unrelated or sensitive edits;
- the PR body has only its three sections and its raw block stays within 80
  columns;
- the Linear comment has only the two copied French sections and four verified
  Coolify URLs, with Linear, PR, and Mattermost reporting the same result.
