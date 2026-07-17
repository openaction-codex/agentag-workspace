# Default Critical-Path Test Plan

Use this plan only when the user supplies no test plan. Execute every required
path in order. Keep paths read-only until the contact-lifecycle path creates a
synthetic record owned by the run.

## Shared test data

- Generate one run ID: `VP-YYYYMMDD-HHMMSS`.
- Authorized email recipient: `agent@openaction.eu` only.
- Synthetic contact email: use `agent+<run-id-lowercase>@openaction.eu` if the
  form accepts plus addressing; otherwise use the authorized mailbox and put
  the run ID in a dedicated external ID, tag, first name, or last name field.
- Synthetic names: first name `Validation`, last name `<run-id>`.
- Use no real person's name, address, phone number, membership, payment, or
  political data.

## 1. Reachability and authentication

Required.

1. Open the supplied URL and verify it is clearly a non-production environment.
2. Verify the login form is usable and does not expose an application error.
3. Sign in with the credentials defined in `SKILL.md`.
4. Verify a successful authenticated landing page, the expected account or
   organization context, and the absence of an authentication loop.
5. Reload once and verify the session remains authenticated.

Expected: the console loads in the correct preproduction environment and the
authenticated session is stable.

## 2. Main navigation smoke test

Required.

1. Identify the main console navigation.
2. Open the dashboard or home, CRM/contacts, and email/campaigns modules.
3. Return to the starting module using visible navigation.
4. Verify each page renders its main heading or primary content and navigation
   remains available.

Expected: core modules load without broken routing, blank screens, or relevant
console/network failures.

## 3. CRM access and list

Required.

1. Open the CRM or contacts module.
2. Verify the contact list, its columns or cards, result count when present,
   pagination or scrolling, and primary search/filter controls.
3. Open one existing contact read-only, note only a non-sensitive UI identifier
   for evidence, and return to the list without editing.

Expected: the CRM list and an existing contact detail are accessible and
render consistently. If the environment contains no existing contacts, record
that fact and continue with the synthetic contact path rather than inventing one.

## 4. Contact search

Required.

1. Search for the exact run-owned synthetic contact if it already exists;
   otherwise search for a clearly visible, non-sensitive value from the list.
2. Verify returned rows actually match the query.
3. Search for the impossible value `NORESULT-<run-id>`.
4. Verify a clear zero-result or empty state.
5. Clear the search and verify the original list or count returns.

Expected: positive, negative, and reset search behaviors are correct.

## 5. CRM filters

Required when filters are present; `BLOCKED` if CRM should expose filters but
the controls are unexpectedly absent.

1. Open the filter interface and identify available low-risk criteria such as
   contact status, tags, subscription status, creation date, or organization.
2. Apply one criterion whose matching result can be verified from visible rows
   or count. Verify every returned visible row is compatible with the filter.
3. Combine it with a second criterion when the UI offers one and verify the
   results narrow or remain logically consistent.
4. Remove one criterion and verify the remaining filter persists.
5. Clear all filters and verify the baseline list or count returns.
6. Reload after applying a harmless filter only when the UI is expected to
   persist filters; verify the documented or visibly implied behavior.

Expected: filters apply, combine, remove, and reset correctly; result evidence
must come from rows, counts, or an explicit empty state, not chips alone.

## 6. Synthetic contact lifecycle

Required when the authenticated role exposes contact creation. If the module
is intentionally read-only, classify this path `NOT APPLICABLE`; if permission
or UI behavior is unclear, classify it `BLOCKED`.

1. Create one contact using the shared synthetic data and the minimum required
   fields. Verify validation rejects one deliberately omitted required field
   before submitting valid data.
2. Verify success, open the created contact, and confirm exact persisted values.
3. Return to the CRM list and find the contact by its run ID using search.
4. Edit one harmless run-owned field, such as first name or a test tag, save,
   reload, and verify persistence.
5. Do not merge with, subscribe, donate for, or otherwise affect an existing
   contact.

Expected: create, validation, lookup, update, and persistence work for the
run-owned contact.

## 7. Email composition and sending

Required when the email/campaign module and authorized sender are available.
If the environment intentionally routes mail to a visible mail sink, use and
verify that sink. Otherwise verify UI enqueueing only.

1. Open the email or campaign module and start a new draft.
2. Use a name and subject containing the run ID, for example
   `Validation preprod <run-id>`.
3. Add a short plain-text body stating that it is an automated preproduction
   validation and can be ignored.
4. Select only the authorized test mailbox as the recipient. Prefer a direct
   test-email feature. If only audience/campaign sending exists, create or use
   a segment proven through visible UI to contain exactly the run-owned contact
   and no other recipient.
5. Before sending, re-check the final recipient count and address. It must be
   exactly one authorized recipient; otherwise stop and mark the path `BLOCKED`.
6. Send, then verify the visible queued, sent, or accepted confirmation and
   the draft/campaign status. Do not equate this with inbox delivery.

Expected: composition, recipient selection, final safety check, and email
enqueueing succeed without sending to a real or unauthorized contact.

## 8. Cleanup

Required for data created by the run, but cleanup must not hide evidence and
must not begin without explicit user confirmation.

1. Capture the final functional evidence first.
2. Ask the user to confirm deletion of the identified run-owned records. If no
   confirmation is received, retain them and report their identifiers.
3. After confirmation, delete or archive only the run-owned email draft/campaign if the UI offers a
   clearly safe action and doing so does not erase send evidence.
4. Delete only the synthetic contact created by the run if deletion is clearly
   scoped to that exact record and is recoverable or expected in preproduction.
5. Never delete a pre-existing contact, shared audience, template, or campaign.
6. If safe cleanup is unavailable or uncertain, retain the data and report the
   exact run ID and visible record identifiers for manual cleanup.

Expected: only run-owned disposable data is removed, or retained artifacts are
precisely documented without making the functional validation fail by itself.

## 9. Session termination

Required.

1. Use the visible logout action when available and verify return to an
   unauthenticated page without an error.
2. Close the isolated browser session.
3. Confirm that no authentication-state file or persistent profile remains.

Expected: the session is terminated cleanly and no reusable credentials or
authentication state are retained locally.
