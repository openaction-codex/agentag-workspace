---
name: research-sales-account
description: Research a prospective or existing sales account from only an organization name, domain, or legal entity; identify 1-3 ideal professional contacts; and produce an evidence-backed, action-oriented OpenAction sales brief. Use when an employee asks to research, qualify, investigate, find decision-makers at, prepare outreach to, or understand a company, association, NGO, union, political organization, campaign, federation, public-interest organization, or other potential customer.
---

# Research Sales Accounts

Turn a minimal account identifier into a concise sales brief that helps an
OpenAction employee decide what to say, ask, and do next.

## Inputs

Require only one of:

- organization name;
- domain or website URL;
- legal entity name or registration identifier.

Use optional context when supplied: country, known contact, deal stage, meeting
objective, suspected need, or existing notes. Do not ask for optional context
before starting. Ask a concise question only when entity ambiguity would make
the research materially unreliable and cannot be resolved from public sources.

## Operating rules

- Browse the web for every account. Prefer current primary sources and public
  registries over aggregators, search snippets, or vendor marketing databases.
- Research the organization for legitimate B2B sales preparation. Do not build
  dossiers about private lives or infer sensitive personal attributes.
- Treat a source as evidence, not truth. Cross-check consequential claims.
- Distinguish `Confirmed fact`, `Supported inference`, and `Unknown`.
- Attach a direct source and date to each consequential external claim. State
  confidence as high, medium, or low.
- Never invent revenue, budget, headcount, technology, stakeholders, or intent.
- Do not equate a brand, website, campaign, parliamentary group, foundation,
  association, or parent entity until evidence connects them.
- Do not bypass authentication, paywalls, access controls, robots restrictions,
  or technical protections.
- Do not contact anyone, subscribe to anything, submit forms, or update external
  systems. Research is read-only.
- Write in the language of the user's latest message unless they request another
  language. Preserve official names in their original language.

Read [research-method.md](references/research-method.md) before researching.
Use [report-template.md](references/report-template.md) for the final answer.

## Workflow

### 1. Resolve the entity

Identify the canonical organization, country, official domain, legal form, and
any relevant parent, chapter, campaign, foundation, or operating entity.

If multiple candidates remain plausible, present the ambiguity and continue
only with clearly separated candidate findings. Never silently merge them.

### 2. Build the evidence base

Research the categories in `research-method.md`, adapting depth to evidence
availability and likely relevance. Follow promising evidence rather than
mechanically filling every field.

Financial research must distinguish filed figures from estimates and capacity
proxies. Technology research must distinguish confirmed vendor disclosures or
configuration evidence from browser-visible hints. Absence of visible evidence
does not prove absence of a system.

### 3. Assess OpenAction fit

Evaluate fit using evidence, not a fabricated numeric score:

- audience or member/contact management needs;
- communication and mobilization needs;
- website, CMS, campaign, form, event, payment, or automation needs;
- fragmented tools or data;
- decentralized teams, chapters, territories, or permission needs;
- scale and operational complexity;
- sovereignty, GDPR, security, governance, or autonomy requirements;
- plausible capacity, timing, and procurement path.

Rate overall fit `Strong`, `Plausible`, `Weak`, or `Unknown`. Explain the two or
three factors that determine the rating and name any disqualifier.

### 4. Convert evidence into sales hypotheses

Create at most three hypotheses. For each one include:

- the suspected problem or opportunity;
- supporting evidence;
- confidence;
- what would disprove it;
- one discovery question.

Frame hypotheses as possibilities to validate, never as claims about the buyer.

### 5. Identify 1-3 ideal contacts

Find and rank one to three named people who are the strongest plausible entry
points for selling OpenAction. Do not merely list the most senior leaders.
Balance:

- ownership of the likely problem;
- influence over digital, communications, CRM, membership, fundraising,
  organizing, operations, data, IT, procurement, or budget decisions;
- ability to sponsor or evaluate a cross-functional platform;
- relevance to the observed buying signal;
- recency and strength of evidence that the person still holds the role;
- availability of a legitimate professional contact route.

Aim for complementary buying roles when the organization supports them:

1. the operational problem owner or likely champion;
2. the digital, data, or technical evaluator;
3. the executive, budget, or organizational sponsor.

For each person provide their current title, likely buying role, why they are a
good contact for this specific account, evidence, confidence, recommended angle,
and best verified professional route. A route may be an official work email,
official contact page, professional profile, named conference/network channel,
or evidenced warm introduction path.

Never guess an email pattern, use enrichment databases as sole evidence, or
include private/personal contact details. If no named person can be verified,
state that clearly and recommend the exact role or team to approach through the
organization's official channel. One strong contact is better than three weak
ones.

### 6. Recommend an action

Choose one concrete next action:

- personalize an initial approach;
- prepare a discovery conversation;
- approach through a partner or warm route;
- monitor a named signal;
- nurture for a later trigger;
- investigate one blocking unknown;
- disqualify for now.

If outreach is recommended, draft one short opening message grounded in a
relevant professional signal. Avoid surveillance-like detail, generic praise,
false familiarity, urgency, or unsupported claims.

### 7. Deliver progressively

Put the decision-useful brief first and detailed evidence afterward. A seller
should understand the account, fit, and next action in about 90 seconds without
reading the appendix.

Do not pad unavailable categories. Say `Not found in public sources` or explain
the exact uncertainty. Keep most briefs under 1,500 words unless the user asks
for a detailed dossier or the account is unusually complex.

## Privacy and prospecting safeguards

- Include people only when their publicly stated professional role is relevant
  to the buying process. Keep personal detail limited to their name, current
  professional role, relevant public work, and verified professional route.
- A publicly posted organizational work email or official professional profile
  may be reported when relevant. Do not collect personal phone numbers, private
  email addresses, home addresses, family information, or unrelated social
  activity, and never infer an email address from a domain pattern.
- Do not infer political opinions, trade-union membership, religion, health,
  ethnicity, sexual orientation, or other sensitive attributes about a person.
  An official professional role in an organization may be reported as such,
  without extrapolation.
- Clearly identify the public source of any professional personal data.
- Treat drafted outreach as a human-review draft. Remind the user to apply the
  organization's prospect-information, lawful-basis, opt-out, and suppression
  procedures before use when personal data is involved.

## Quality check

Before answering, verify:

- the researched entity matches the requested account;
- important sources are direct, current, and diverse where possible;
- facts, inferences, and unknowns are visibly separated;
- financial and technology claims carry appropriate caveats;
- the fit assessment maps to actual OpenAction use cases;
- every hypothesis can be tested through a discovery question;
- one to three contacts are ranked by account-specific relevance, or the exact
  missing role is reported without inventing a person;
- every named person's current role and contact route are supported by a direct,
  recent public source;
- the recommended action follows from the evidence;
- no sensitive inference, unnecessary personal data, or invented detail is
  present;
- every link opens the page supporting the associated claim.
