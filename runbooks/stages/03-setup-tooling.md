# 03 — Setup Tooling

## Use / Owner

Use after initial Planning or when tooling needs change. CODER owns Setup; INFRA supports only parent-assigned infrastructure/CI slices. This library checkout is not the target application.

## Read / Inputs

Read [Setup Tooling](../../process.md#3-setup-tooling) in full, especially artifact agreement, target project instructions, and readiness. Read the three current planning documents at the brief's resolved absolute `PLANNING_DIR` paths and existing applicable instructions. Planning inputs are read-only here; external documents must not be copied into or committed to the checkout. Load [Static Analysers](../../static-analysers.md), [Dependency Checking](../../dependency-checking.md), and the [CRAP runbook](../CRAP-runbook.md) for the selected languages/configuration. These are on-demand Setup references, not prerequisites to conversation in Research.

## Execute

1. Confirm absolute process-root versus target/project-root and allowed edits. Preflight the running harness's required capabilities from its section of [harnesses.md](../../harnesses.md), discoverable/enabled role agents, stage skills, runtimes, tools, and loaded providers. Distinguish enforced restrictions from instruction-based role boundaries and disclose limitations; missing required isolation blocks affected work. Confirm the native messaging or stop-and-return supervisor exchange. Ask through the parent for installation/global configuration authority; do not install automatically.
2. Agree external artifact root (canonical default or approved alternate), absolute per-run `ARTIFACT_DIR`, classes, ledger permission, access, retention, and cleanup. Preserve the standard subfolders and checkout/run separation. Configure canonical/symlink-safe routing of outputs and caches inside that root and outside the checkout, separate from planning inputs; resolve tools that cannot comply.
3. Configure the canonical project Make interface, selected tools, pinned CRAP profiles/adapters, strict policy, and dependency checker across relevant components. Preserve failures and nonmutating validation; keep audit separate from Coding aggregates.
4. Create/update **target** `AGENTS.md` with actual commands, process responsibilities, `PLANNING_DIR` and its access/selection rule, `ARTIFACT_DIR` routing/allocation rule, measurement policy, verification-skill task, and artifact agreement. Record the actual resolved paths in each brief. Do not copy the library bootstrap unchanged.
5. Inspect every canonical readiness item and demonstrate tool invocability. Setup configures audit/CRAP targets; running dependency auditing, collecting project coverage, or a runtime verification audit is not required for Setup readiness.

## Handoff / Stop

Return source changes, capabilities, agreement, readiness evidence, and blockers. Missing authority blocks readiness, not a license to install. Continue to Coding only within parent/user approval and stop points.
