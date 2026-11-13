# 05 — Reviewing

## Use / Owner

Use for explicitly bounded checks or full Stage 5. Independent REVIEWER verifies; CODER owns all source/PoC/test/fix mutations. A bounded result is not whole-stage signoff.

## Read / Inputs

Read [Reviewing](../../process.md#5-reviewing) in full, target instructions and planning documents, exact candidate/base/range plus included working-tree changes, artifact/ledger permission, and required gates. Load references at their check: [pr-code-review](../../skills/pr-code-review/SKILL.md), [ac-review](../../skills/ac-review/SKILL.md), [CRAP runbook](../CRAP-runbook.md), and the supplied target verification skill/feature map. Load [dependency guidance](../../dependency-checking.md) when interpreting the configured audit.

## Execute

For full Stage 5, execute all six canonical checks **in order**:

1. Apply bounded `pr-code-review`: prove causality; route requirements-based red/green fixes to CODER. Require zero OPEN findings and two consecutive CLEAN rounds against green gates for unchanged scope. Use the approved external ledger.
2. Apply `ac-review` with the brief's resolved absolute `PLANNING_DIR/user-stories.md` argument to every in-scope criterion, including pre-existing behavior. All planning inputs remain read-only; never copy external documents into or commit them to the checkout. Inspect meaningful assertions and fresh passing execution; route gaps to CODER and requirement amendments through the parent to PLANNER.
3. Run `make quality-crap`, inspect inventory, mappings, provenance, and fresh coverage. Every eligible production function in scope must have **unrounded CRAP <30**; exactly 30 blocks. No debt ratchet or silent exclusions.
4. Independently assess verification-skill relevance against requirements and intended environments; send missing/stale source to CODER, never edit it as reviewer.
5. Execute real applicable project verification journeys with the assigned serial live-driver slot. Missing prerequisites block completion.
6. Run `make dependency-audit` on the final candidate; remediation returns to Coding and re-audit. Exceptions require user approval.

## Handoff / Stop

Refresh candidate and invalidated earlier evidence after changes; rereview only changed surfaces. Report actual per-step passed/failed/blocked results, commands, findings, convergence, and limitations. Mark unassigned checks not-run/out-of-scope. Full completion requires all six current and green for one final candidate; never infer deployment authority.
