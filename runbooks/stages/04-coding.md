# 04 — Coding

## Use / Owner

Use for bounded approved stories and source remediation. CODER owns implementation, tests, PoCs, fixes, and verification-skill source. The parent owns decisions and routes independent review.

## Read / Inputs

Read [Coding](../../process.md#4-coding) in full, target `AGENTS.md`, and current specification, stories, and build plan. Load [code-simplifier](../../skills/code-simplifier/SKILL.md); load [create-verification-skill](../../skills/create-verification-skill/SKILL.md) if none exists, otherwise [maintain-verification-skill](../../skills/maintain-verification-skill/SKILL.md), including required references before use. Confirm Setup readiness and approved external evidence routing.

## Execute

1. Identify allowed stories, edits, candidate, and build order. Preserve unrelated work. Conflicts or necessary scope changes return through the parent to specification-led Planning; wait for affected documents to align.
2. Implement each acceptance criterion with at least one meaningful automated test asserting its required behavior; run tests and resolve failures. Execution without behavioral assertions does not count. For proven remediation defects preserve requirements-based red-before-green proof; do not fabricate red for missing tests of already-correct behavior.
3. Apply `code-simplifier` to changed code without unrelated cleanup. Then run `make test`, `make lint`, `make static-analysis`, and `make format-check` across configured applicable tools. Fix failures and rerun affected gates. Dependency auditing is Reviewing's separate check.
4. Create or maintain the target project's verification skill, feature map, and owned harness from approved requirements, not merely existing behavior. Resolve multiple candidates through the parent. Exercise the skill's real build/install/user-facing paths under approved permissions; record coverage limits honestly. Revalidate after remediation.

## Handoff / Stop

Return changed files, AC/test mapping, commands/results, candidate identity, skill coverage, and permitted external evidence paths in conversation. Missing prerequisites and blocked checks are not passes. Stop at the approved boundary; no deployment or extra reports are implied.
