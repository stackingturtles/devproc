---
name: maintain-verification-skill
description: Keep an existing project verification skill, owned harness, and feature map aligned with requirements and real user-facing behavior. Use during Coding when the skill exists, after relevant changes, or for a requested maintenance pass; report product regressions without rewriting the contract to hide them.
disable-model-invocation: true
license: MIT
metadata:
  upstream: https://github.com/cursor/plugins/tree/6b0300214a09fd6029cfb7077043125758cd1fd2/pstack/skills/maintain-verification-skill
  upstream-revision: 6b0300214a09fd6029cfb7077043125758cd1fd2
---

# Maintain a verification skill

Maintain the reusable skill and feature map during Coding. Reviewing separately
judges their relevance and executes verification without silently changing the
expected behavior. This is a portable adaptation of the upstream pstack skill;
its MIT notice is in `LICENSE`. It requires no editor-specific plugin.

Example invocation where configured:

```text
/skill:maintain-verification-skill
```

## Outcomes and authority

Return one outcome:

- **clean** — every mapped feature received source and live coverage; no source
  correction is needed and required entry points have honest verification evidence.
- **changed** — bounded, proven skill/map/harness corrections are ready for review.
- **blocked** — required coverage, an environment, approval, or safe execution is
  unavailable, or a product defect prevents completion. Report partial progress
  separately; it is not a clean full pass.

Do not automatically create a branch, commit, push, or open a PR. Those actions
belong to the user's separately authorized workflow.

Only edit the selected verification skill directory: its `SKILL.md`, `features/`,
and owned harness/helper source. Product fixes belong to a separate authorized
Coding task with regression tests. Specifications and acceptance criteria are the
behavioral authority: an implementation change is not by itself permission to
change the map's expected outcomes.

A full maintenance pass covers every mapped feature and checks for omitted required
surfaces. If the user authorizes only a targeted pass, state the exact scope and do
not call it a full maintenance pass or full-product verification. Do not broaden a
bounded task silently; report additional required work to the user.

## 1. Locate the skill and prepare isolated outputs

Read `AGENTS.md`, relevant specification/stories, and the existing verification
contract. Locate `skills/verify-<project>/SKILL.md` and its `features/README.md`.
Several candidates require a choice; none means stop and use
`create-verification-skill` instead. Do not invent a second map elsewhere.

Use the approved absolute `ARTIFACT_DIR` under:

```text
~/.local/state/agent-workflows/<project-key>/<run-id>/
```

Validate canonical paths outside the checkout and inside this root, including
symlinks. Keep all builds, evidence, logs, traces, review notes, caches, disposable
application data, and temporary HOME/profile directories in appropriate subfolders
of that run root. Evidence belongs under `verification/`; scratch belongs under
`scratch/`. Never write run reports into the verification skill, `docs/`, or other
repository folders, or use arbitrary `/tmp` output paths.

Use the artifact policy approved during Setup; ask before extra reports or
unapproved retention. Do not install dependencies, access production/personal
sessions, supply secrets, or trigger external side effects without authority.
The generated skill's actual harness requirements must be present; missing tools
or prerequisites are blockers, not permission for automatic installation.

## 2. Check index hygiene and source behavior

Read the map index and compare its links with sibling feature files. Correct
missing, duplicate, dead, or unindexed entries where their intended ownership is
clear. If an existing skill has no map, seed its index and required feature files
from approved requirements using the schema in
[the shared example](../create-verification-skill/references/feature-map-example/README.md),
not a second authoritative map elsewhere. Do not create a separate inventory
report by default.

For every mapped feature, inspect its requirements and actual source entry points.
Return a concise feature summary, source citations, likely drift or none, and a
live-verification recipe. Use bounded read-only subagent tasks when delegation is
authorized and available; group small features or inspect directly when that is
cheaper. Source readers never drive shared application state or edit files. A
failed delegation is a blocker to resolve, not permission to switch mechanisms
silently.

Reconcile all summaries before live driving. Merge overlapping setup into as few
app states as practical, while preserving required entry points. Sweep changed
surfaces for missing required features; require a concrete requirement or source
path before calling one missing. Do not redefine intended behavior from code alone.

## 3. Drive the real mapped features

The coordinator owns live driving, serially, with source readers kept read-only.
Follow the selected skill's Launch model: a long-lived isolated instance for a
server/UI, or fresh owned sessions for short-lived CLIs. Full maintenance requires
live exercise of every feature and the required mapped entry points; source
inspection alone cannot establish clean results.

Maintain these invariants:

1. **Doctor before trust.** Doctor before first drive and every fresh session,
   and again after failed or surprising behavior. If the process is healthy but
   UI state is wedged, reset owned state or relaunch rather than continuing blindly.
2. **Evidence survives cleanup.** Capture the action and observable result plus
   required side effects. Verify retained evidence exists at its external path
   after every cleanup, including failed attempts.
3. **Own the lifecycle.** Stop only processes and remove only scratch/fixture
   state the run created. Do not kill by process name, delete retained evidence,
   or interfere with another instance. Clean failed-iteration residue as well.

A Doctor failure caused by proven skill drift may receive one bounded correction
and retry, restarting only what the correction invalidates. Persistent failure is
blocked. For an unreachable feature, record the attempted entry point and concrete
missing prerequisite—authorization, entitlement, OS, fixture, or external state.
Documenting unreachability is not proof the feature passed. Required unreachable
journeys prevent a full clean outcome.

## 4. Triage without weakening requirements

- **Description/map drift:** correct instructions only when requirements and
  observed behavior justify the correction. Keep stable feature IDs and update
  the index and cross-references consistently.
- **Harness gap:** correct owned selectors/helpers or launch/doctor commands.
  Make helper invocations explicit and set executable modes where applicable.
- **Product regression:** report it with behavioral evidence and hand it to the
  authorized coding agent for a requirements-based red-to-green fix. Do not edit
  product code within this maintenance pass or rewrite the expected result to
  make broken behavior look correct.
- **Unclear requirement:** ask the user; do not choose whichever interpretation
  makes the current implementation pass.

Re-drive every changed harness instruction or affected journey. If separate product
remediation changes the candidate, invalidate and repeat affected source/live
checks before reporting completion. Perform final teardown after all re-proofs,
not before a final drive that leaves processes behind.

## 5. Hand off or stop

Reread changed source files, confirm their scope, and report the outcome,
features/entry points exercised, commands, external evidence paths, limitations,
and blockers in conversation. Optional concise run notes belong only in the
approved external artifact folders; do not commit them or generate unsolicited
reports.

Keep corrections as local source deliverables for the normal review workflow.
Do not claim they shipped merely because they were edited. Stop on repeated
no-progress failures or unsupported prerequisites rather than looping indefinitely.
The independent reviewer must still assess skill/map relevance and execute the
required project verification on the final review candidate.
