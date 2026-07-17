---
name: validate-preprod
description: "Validate an OpenAction preproduction environment from a supplied URL, with an optional user-provided test plan. Use when asked to test, QA, smoke-test, recette, or validate a preprod/staging environment independently of a Pull Request or Linear issue. Execute the supplied journey when present; otherwise run the bundled critical-path console test plan covering authentication, navigation, CRM access, contact search and filters, contact lifecycle, and a safe email send."
---

# Validate an OpenAction Preproduction Environment

Validate a supplied preproduction URL through the visible UI and return a
concise, evidence-backed result. Do not require a Pull Request, repository, or
Linear issue, and do not publish comments or change external workflow statuses.

## Inputs

Require:

- one explicit preproduction URL.

Accept optionally:

- a test plan written in the prompt or supplied as an accessible attachment;
- specific fixtures, expected results, applications, browsers, or exclusions.

Treat the supplied test plan as authoritative. Add only the smallest smoke
checks needed to authenticate, reach the requested feature, and detect an
obvious adjacent regression. When no test plan is supplied, read and execute
[the default critical-path plan](references/default-test-plan.md) completely.

Ask for clarification only when the target URL is missing or the supplied plan
has a material ambiguity that cannot be resolved safely from the UI.

## Operating rules

- Follow the workspace `AGENTS.md` and applicable local instructions.
- Load and follow the `playwright-cli` skill for all browser operations. First
  require `command -v playwright-cli` to succeed. If unavailable, report the
  validation as `BLOCKED`; do not install it or substitute another browser tool.
- Validate only the exact supplied preproduction host and its same-environment
  redirects or sibling applications discovered through visible navigation.
  Never derive a target, switch to production, or follow a link whose
  environment is uncertain.
- Use visible UI controls. Do not use JavaScript evaluation, storage edits,
  request mocking, or direct API calls to bypass product behavior.
- Do not modify application code, repositories, Linear issues, Pull Requests,
  or deployment state.
- Use the credentials below only on the supplied preproduction console login:
  - username: `agent@openaction.eu`
  - password: exact content of the file `/root/openaction-preprod-password.txt` 
    on this server
- Treat credentials as secrets. Never repeat them in commentary, reports,
  screenshots, snapshots, traces, shell history excerpts, filenames, or saved
  authentication state. Do not persist a browser profile or authentication file.
- Never send email to anyone except `agent@openaction.eu`. Never export CRM
  data, initiate a payment, publish content, or contact real users by default.
- Never alter or delete pre-existing records. Create only uniquely named,
  non-sensitive test data required by the plan. Before deleting even run-owned
  test data, ask the user for confirmation after evidence is captured. Without
  confirmation, retain the record and report its exact unique identifier.
- Stop a path before any action whose scope, recipient, environment, or effect
  is uncertain, and classify that path as `BLOCKED`.

## Prepare the journey

1. Normalize the supplied plan into ordered paths. For each path, record its
   starting state, fixture, UI actions, expected visible result, and safe
   cleanup. Preserve the user's sequence and exact data.
2. If no plan is supplied, load the entire default plan. Adapt labels and menu
   names to the UI, but do not silently omit a required path.
3. Discover suitable pre-existing fixtures through read-only UI inspection.
   Never invent a contact or organization that is expected to exist.
4. Use a run identifier such as `VP-YYYYMMDD-HHMMSS` for every created record,
   email subject, and retained artifact. Use only synthetic, non-sensitive data.
5. Mark a path `BLOCKED` when it requires an unavailable module, permission,
   fixture, safe recipient, or product decision. Record the precise blocker.

## Execute with playwright-cli

1. Create one isolated in-memory named session, for example
   `validate-preprod-YYYYMMDD-HHMMSS`, and open the exact quoted URL.
2. Capture the starting URL and focused snapshot, authenticate through the
   visible login form, and verify the post-login identity and environment.
3. Execute paths in order. After every meaningful action, verify the expected
   visible state with a focused snapshot or read-only element inspection.
4. For searches and filters, verify both the narrowed result and restoration
   after clearing the criterion. Do not report success from control state alone.
5. For created or edited data, verify persistence after navigation or reload.
6. For email, verify the exact recipient before the final send action. Send
   only to `agent@openaction.eu`, use the run identifier in the subject, and
   verify the visible queued/sent confirmation. Do not claim inbox delivery
   unless the plan supplies authorized mailbox access and it is actually checked.
7. After each path, inspect `playwright-cli console` and
   `playwright-cli requests`. Correlate relevant errors and failed requests with
   the action; distinguish preview noise without silently ignoring it.
8. Capture concise evidence without secrets or unrelated personal data. Prefer
   snapshots and targeted screenshots. Redact or omit personal data that is not
   necessary to establish the result.
9. After evidence capture, request confirmation before deleting run-owned data.
   If confirmed, clean it up through the visible UI. Otherwise retain it and
   report its identifier. A cleanup failure does not erase the functional
   result, but must be reported as a blocker requiring manual action.
10. Close the browser session and remove any sensitive local artifact created
    by the run.

## Classify results

Classify each path and the overall validation:

- `PASSED`: all required actions ran on the target preprod, visible outcomes
  matched, and no relevant console or network defect was observed.
- `FAILED`: a visible outcome is wrong, a regression is reproduced, or a
  relevant console error or failed request demonstrates a defect.
- `BLOCKED`: a required URL, module, fixture, authorization, safe action, or
  browser capability is unavailable, so correctness cannot be established.
- `NOT APPLICABLE`: the path is explicitly outside the supplied environment's
  product scope. Use only when the UI provides clear evidence; missing access
  or an unexpected absence is `BLOCKED`, not `NOT APPLICABLE`.

Use `FAILED` overall when any required path fails, even if another is blocked.
Otherwise use `BLOCKED` when any required path is blocked. Use `PASSED` only
when all required paths pass; optional or clearly non-applicable paths do not
prevent a pass. Never infer success from code inspection or page reachability.

## Report evidence

Return a concise report in the user's language:

```markdown
Status: PASSED | FAILED | BLOCKED

- Target: <preproduction URL>
- Journey: <user-provided | default critical-path plan>
- Run ID: `<identifier>`
- Cleanup: <completed | retained records and reason | not needed>

| Path | Fixture | Actions and visible result | Console/network | Status |
| --- | --- | --- | --- | --- |
| <name> | <safe fixture> | <concise evidence> | <relevant evidence> | <status> |

Defects or blockers: <reproduction, impact, and missing evidence>
Email: <recipient redacted as authorized test mailbox, subject/run ID, UI send result>
Artifacts: <safe absolute paths to retained screenshots or traces>
```

Do not reproduce credentials, authentication tokens, contact personal data,
raw logs, or long traces. State clearly when email enqueueing was verified but
delivery was not.
