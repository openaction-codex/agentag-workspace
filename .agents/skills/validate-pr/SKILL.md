---
name: validate-pr
description: "Validate an OpenAction implementation from a Linear issue ID or GitHub pull request number or URL. Use when asked to test, QA, or validate a PR through its French test journey: route non-Europe issues directly to Human: To review, use Europe Coolify preview URLs for real functional validation, execute the flow with playwright-cli, post matching French GitHub and Linear comments, and report evidence as passed, failed, or blocked."
---

# Validate a Pull Request

Validate Europe implementations against their accepted behavior in the Coolify
preview. For every other repository, skip browser validation because Coolify
preview URLs are not available and move the Linear issue directly to
`Human: To review`.

## Inputs

Accept one of:

- a Linear issue ID, such as `OPE-123`;
- a GitHub PR number, such as `#123`, optionally with `owner/repo`;
- a GitHub pull request URL.

Ask the user to choose only when the input resolves to multiple plausible PRs.

## Operating rules

- Follow the repository's `AGENTS.md` and local contribution instructions.
- Use the GitHub and Linear access available in the local environment. Require
  complete PR and issue context plus the ability to publish the required
  comments and status updates; stop and report a missing capability.
- Load and follow the `playwright-cli` skill for all browser navigation,
  interaction, snapshots, console inspection, and network inspection. Before
  opening a preview, verify that `command -v playwright-cli` succeeds. If it
  does not, report the validation as blocked; do not install it or silently
  substitute `npx`, a browser connector, `curl`, or another automation tool.
- For Europe, this skill updates Linear status, posts one GitHub PR comment,
  posts one Linear comment with the same content, and then moves Linear to
  `Human: To review`. For non-Europe repositories, move Linear directly to
  `Human: To review` and do not post preview-validation comments.
- Never test on production or with production data. Only work on the preview 
  environments (which are safe, no risky capability).
- Do not modify implementation code while validating. When local inspection is
  needed, use the relevant repository checkout, preserve unrelated work, and
  inspect the PR head without changing it.

## Resolve the validation context

1. For a Linear input, read the complete issue, comments, links, and
   attachments. Resolve its implementation PR and repository from verified
   links. For a PR input, resolve the repository and read its linked Linear
   issue when present.
2. Read the PR metadata, complete body, current head SHA, changed files and
   diff, conversation comments, checks, and statuses. Determine whether the
   repository is `citipo/openaction-europe`. Read deployments or Coolify
   comments only when they are relevant. Retrieve complete paginated results.
3. Treat the latest Linear clarification as accepted behavior. Record any
   disagreement among Linear, the PR description, and the current
   implementation before testing.
4. Require a resolved Linear issue before changing status or posting the Linear
   validation comment. If a PR input has no linked Linear issue, stop and ask
   for the issue ID.
5. If the repository is not `citipo/openaction-europe`, move the Linear issue
   directly to `Human: To review`, report that Coolify validation is not
   applicable for this project, and stop. Do not wait for preview URLs, run a
   substitute browser validation, or mention preview URLs in the summary.

## Europe validation lifecycle

For `citipo/openaction-europe` only:

1. Move the Linear issue to `Validation in progress` before opening the
   preview environment.
2. Execute the validation workflow below against the current PR head and
   Coolify preview URLs.
3. Post one GitHub PR comment and one Linear comment with exactly the same
   French validation summary.
4. Move the Linear issue to `Human: To review` whether the validation passed,
   failed, or was blocked. The comments must make failures and blockers clear.

## Recover or design the test journey

1. Locate the latest `## Parcours de test sur la prévisualisation` section in
   the PR body. If needed, compare it with the copy in the linked Linear issue
   or comment, but prefer the current PR body for the current implementation.
2. Use the existing French journey only when it names every required app,
   exact fixture or test record, navigation path, UI action, and visible
   expected result. Preserve its sequence and data exactly.
3. If the section is absent or unusable, design a French journey from the
   accepted Linear behavior, PR diff and body, relevant current code, and
   verified safe fixtures. Inspect fixture definitions before naming a record;
   never invent a fixture or substitute production data.
4. Cover the primary changed behavior, its important permission, validation,
   or edge path, and the smallest adjacent regression paths justified by the
   diff. Keep every step observable through the UI and identify the expected
   visible result.
5. If a required fixture, account role, product decision, or safe action
   remains unknown, mark the affected path blocked instead of improvising.

## Resolve the target environment

1. For `citipo/openaction-europe`, read the Coolify bot comment on the resolved
   PR. Accept only URLs explicitly present in a comment for that PR and current
   head. Never derive, edit, copy from another PR, or guess a preview URL.
2. For Europe, match each URL to its named application, such as `console`,
   `public`, `platform`, or `mobilisation`. Use every app required by the
   journey and regression paths; do not require an unrelated app.
3. Mark a path blocked when its required Europe Coolify URL is missing,
   ambiguous, stale, unreachable, or unsafe. Report the exact missing evidence.
4. Use only an already authorized login or browser state. Never expose
   credentials in commands, snapshots, GitHub, Linear, or the final summary.
   Mark an authenticated path blocked when the required access is unavailable.

## Execute the journey with playwright-cli

1. Create an isolated in-memory named session per app, for example
   `validate-pr-123-console`, and open the exact quoted target URL. Do not use
   a persistent profile unless the user supplies an authorized one.
2. Capture the starting URL and a focused snapshot. Follow the planned
   navigation, actions, and fixture data exactly through visible UI controls.
   Do not use JavaScript evaluation, storage edits, request mocking, or direct
   API calls to bypass application behavior.
3. After every meaningful action, verify the expected visible state with a
   focused snapshot or read-only element inspection. Check persistence after
   navigation or reload when it is part of the accepted behavior.
4. Run the relevant adjacent regression paths in the same way. Keep them
   proportional to the changed area; do not broaden validation into a generic
   product tour.
5. After each path, inspect `playwright-cli console` for errors and
   `playwright-cli requests` for failed requests. Inspect relevant request
   details and correlate them with the action. Distinguish harmless or known
   preview noise from evidence of an introduced defect; do not silently ignore
   either.
6. Capture concise evidence: application and URL, exact fixture, key actions,
   final visible outcome, relevant console errors, failed requests, and a
   focused screenshot or snapshot when it materially supports the result.
   Exclude tokens, credentials, personal data, and unrelated internal logs.
7. If the journey creates data, use a unique non-sensitive test value and
   record it. Clean up only data created by this run, only through a safe
   preview UI path, and only when cleanup cannot hide the failure. Never delete
   a shared fixture or pre-existing record.
8. Close every named browser session. Do not leave authentication-state files
   or other sensitive artifacts behind.

## Classify the result

Classify every required path and the overall validation:

- `PASSED`: every required path ran on the current target environment with its
  exact fixture, all visible outcomes matched, and no relevant introduced
  console or network failure was observed.
- `FAILED`: a visible outcome is wrong, an adjacent regression is reproduced,
  or a relevant console error or failed request demonstrates a defect.
- `BLOCKED`: a required PR, target URL, fixture, authorization, safe action, or
  `playwright-cli` capability is unavailable, so correctness cannot be
  established.

Use `FAILED` overall when any required path fails, even if another path is
blocked; list both. Otherwise use `BLOCKED` when any required path is blocked.
Never report `PASSED` from code inspection alone or when authentication,
fixture, URL, or a required path was unavailable.

## Report evidence

Return a concise report containing:

```markdown
Status: PASSED | FAILED | BLOCKED

- Input: <Linear issue and/or PR link>
- PR head: `<SHA>`
- Journey: <existing PR section | designed from verified context>
- Target: <Europe Coolify app URL>

| Path | App and fixture | Actions and visible result | Console/network | Status |
| --- | --- | --- | --- | --- |
| <name> | <app, fixture> | <concise evidence> | <relevant evidence> | <status> |

Regressions: <paths checked and result>
Defects or blockers: <reproduction, impact, and missing evidence>
Artifacts: <safe local snapshot, screenshot, or trace paths when retained>
External publication: GitHub PR comment and Linear comment posted
```

## Europe GitHub and Linear comments

Before publishing comments, re-read the remote PR head SHA. If it changed,
refresh context and rerun affected paths before writing.

Post the same French Markdown body as a GitHub PR comment and a Linear comment:

```markdown
## Résultat de validation

Statut : <Réussi | Échoué | Bloqué>

<Résumé court du résultat fonctionnel, en français non technique.>

## Parcours vérifiés

- <Parcours, application, fixture, actions principales, résultat observé>

## Problèmes détectés

- <Bug, régression, erreur console/réseau pertinente, ou blocage avec impact>

## Éléments de preuve

- PR : <URL>
- Commit testé : `<SHA>`
- Prévisualisation : <app et URL Coolify utilisée>
- Artefacts : <capture, snapshot ou trace conservée, si utile et sans secret>
```

Use `Aucun problème détecté.` under `Problèmes détectés` when validation
passes. Keep the comment concise and safe for humans; do not include secrets,
tokens, personal data, raw logs, or long traces.
