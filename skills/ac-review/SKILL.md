---
name: ac-review
description: Compare feature user-story acceptance criteria with meaningful, passing automated test evidence. Use when reviewing docs/<feature-name>/user-stories.md for behavioral test gaps, validating acceptance-criterion coverage on an exact candidate, or handing authorized missing tests and demonstrated implementation gaps to a coding agent for remediation and independent revalidation.
---

# Acceptance-Criterion Review

Review every in-scope acceptance criterion against executable behavioral evidence,
regardless of language or test framework. Identify gaps without turning this into
a whole-product audit or treating an AC assessment as a complete review or release
approval.

Example invocation:

```text
/skill:ac-review docs/account-registration/user-stories.md
```

This illustrates invocation where the skill is available; it does not install or
register the skill.

## Establish scope and authority

Before assessing evidence:

1. Resolve the exact `docs/<feature-name>/user-stories.md` and included stories.
   Read the associated specification for intent, exclusions, and context, plus
   applicable `AGENTS.md`, test configuration, and relevant implementation and
   test files. Inspect all included criteria, including pre-existing behavior,
   not only changed code or recently added tests.
2. Identify the exact candidate commit and included working-tree changes, or an
   equivalent identifiable source snapshot. Record enough identity to detect
   later changes; preserve unrelated work. Establish commands, working directory,
   relevant components, runtime/tool versions, and required environment without
   exposing secrets. Results must be attributable to this candidate.
3. Determine required focused tests and common gates from project instructions:
   `make test`, `make lint`, `make static-analysis`, and `make format-check`, or
   documented equivalents covering the relevant components.
4. Record whether remediation is explicitly authorized and its bounds. The
   invoking process stage may already authorize coder remediation; do not request
   the same permission repeatedly. Review-only means no mutations: do not edit
   implementation, tests, fixtures, configuration, or story documents.

If scope or the candidate cannot be inferred safely, ask the user for the missing
input. Do not substitute the entire product. Resolve specification/story conflicts
or ambiguous requirements with the user; do not derive new acceptance requirements
from specification context. Disclose missing tools or environment prerequisites.
Do not automatically install dependencies, probe networks, or obtain secrets.
Validation must not mutate source or requirements. Approved build/test output,
logs, caches, and scratch state must use the external `ARTIFACT_DIR` under
`~/.local/state/agent-workflows/<project-key>/<run-id>/`, never the repository.
Validate resolved output paths, including symlinks. If execution needs unauthorized
writes or external side effects, disclose the blocker rather than authorizing them.

## Enumerate and trace each criterion

Copy each criterion verbatim into the conversational assessment. Give it a stable
identity using the Linear story ID, or exact story title when no ID exists, plus
criterion ordinal and exact text. Do not edit stories to add identifiers or mark
checkboxes. Changing those documents requires explicit user permission.

For each criterion, inspect the actual test setup, exercised path, and assertions.
Map required clauses to evidence: outcomes, required side effects, prohibited
behavior, and relevant negative or error paths. Require those paths when the
criterion demands them, not as invented requirements. One test may support several
criteria; several tests may jointly demonstrate one criterion.

Choose evidence at the intended boundary: unit, integration, or end-to-end as
appropriate. Tests of mocked behavior alone do not establish behavior beyond that
mock boundary. Inspect whether assertions could detect a violation of the actual
criterion rather than merely confirming a stubbed response. Filenames, matching
test names, test counts, execution coverage, and implementation inspection alone
never establish acceptance-criterion coverage.

## Execute and classify

Run the mapped tests against the identified candidate and inspect their actual
results, not only exit codes. Record exact commands, environment qualifications,
and assertion evidence. Assign each criterion one status:

- **COVERED-AND-PASSING** — meaningful assertions demonstrate every required clause
  at the intended boundary, and the mapped tests actually passed in a fresh run
  matching this candidate.
- **MISSING-TEST** — no automated test evidence exists for the criterion.
- **INADEQUATELY-ASSERTED** — tests exist but their assertions, paths, or boundaries
  do not demonstrate the full criterion. Identify the uncovered clauses.
- **FAILING** — executed relevant tests fail; explain the observed failure and
  distinguish a demonstrated behavioral defect from a test defect.
- **BLOCKED-OR-AMBIGUOUS** — requirements, setup, tools, or execution prevent a
  reliable assessment. State what is needed to proceed.

Skipped, expected-failure/xfail, not-run, and stale results cannot establish
COVERED-AND-PASSING. Explain them as gaps or blockers. Setup failures are blockers,
not product-defect proof. Static evidence of a missing test does not prove an
implementation bug. Where several deficiencies apply, retain their details even
when assigning one summary status.

## Hand off authorized remediation

In review-only mode, report the mapping and gaps and stop without mutations.
Otherwise, use the project's permitted handoff mechanism to send the coding agent
a bounded task: criterion identities and verbatim text, evidence gaps, candidate,
allowed test/implementation scope, and required validation. If that mechanism is
unavailable, disclose the blocker rather than silently becoming the coder.

Require the coder to:

1. Add meaningful missing assertions and tests, including required negatives and
   side effects, without broadening requirements.
2. For an actual implementation defect, demonstrate a requirements-based test
   failing on the original candidate because of that defect before fixing it.
   If a bug-asserting PoC passes by asserting incorrect behavior, preserve that
   evidence and invert it into desired-behavior assertions that fail before the
   fix and pass afterward. Setup failures are not red evidence.
3. If behavior is already correct and only tests are missing, retain the useful
   tests even if they pass immediately. Do not fabricate a red-before-green claim.
4. Make only authorized, bounded fixes. Never weaken criteria or assertions, add
   skips to hide failures, or expand scope to obtain a pass.
5. Run focused tests, then relevant common test, lint, static-analysis, and
   format-check gates. Dependency auditing belongs to Reviewing Step 6, not here.

The reviewer owns independent revalidation: inspect changed assertions and fixes,
rerun affected rows and required gates, and refresh the source-snapshot identity.
Coder summaries alone do not close gaps. Reuse unaffected evidence only when it
still applies to the final snapshot; refresh any invalidated evidence.

## Report and stop

Report scope, candidate, commands/results, each criterion's test/assertion mapping,
status, gaps, blockers, and remediation outcome in conversation. A compact inline
criterion/test/assertion/command-result/status table is sufficient. Persistent
reports, progress logs, coverage ledgers, and similar artifacts require explicit
permission or the policy approved during Setup, and must live in the approved
external project/run folders under `~/.local/state/agent-workflows/`. Never save
review documentation inside the repository. Authorized implementation test sources
and fixtures are source deliverables, not extra process reports.

Stop successfully when every in-scope criterion is COVERED-AND-PASSING and relevant
gates are green for the same final snapshot. Review-only stops with the assessment
and gaps, not a claim that remediation occurred. Stop and disclose blockers or
no-progress remediation instead of looping indefinitely. After changes, revalidate
the affected evidence and gates; do not restart an unlimited whole-code review.
State plainly that this completes only the scoped AC assessment, not the remaining
review steps or release approval.
