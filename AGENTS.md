# Process-library checkout

This directory is a reusable development-process library, **not a target application**. Preserve applicable operator instructions and unrelated changes.

- Start at [README.md](README.md) and the parent-only [development-process router](skills/development-process/SKILL.md). [process.md](process.md#overview) is authoritative for responsibilities, gates, and transitions; load only the assigned stage and its required references.
- Distinguish **process-root** (this library) from **target/project-root** (the separate product checkout). A request to maintain these sources does not authorize executing the workflow, launching children, creating an app, or running application gates. There is no local application runtime or Makefile; do not invent them for documentation maintenance.
- For workflow execution, the parent owns scope, interviews, approvals, routing, stop points, and acceptance. Follow the [shared handoff contract](process.md#shared-roles-and-parent-handoff-contract): bounded briefs, fresh context at responsibility changes, one writer per checkout, and one serial live driver. Missing skills/providers/checks are not passes.
- Follow the canonical [permission boundaries](process.md#shared-roles-and-parent-handoff-contract) and [external artifact policy](process.md#external-artifacts-and-review-records). No implicit installations, global/system config changes, commits, pushes, or deployment. Progress/findings stay in conversation by default; no unsolicited logs, status/review reports, or ledgers. Without an artifact agreement, obtain approval before runtime artifact writes; authorized source planning can continue.
- During [Setup](process.md#project-instructions-agentsmd), CODER creates/updates the **target project's** `AGENTS.md` with its actual tooling and artifact agreement. Do not copy this library-specific bootstrap into an application unchanged.

- Keep shared sources harness-neutral; harness specifics belong only in [harnesses.md](harnesses.md) and `harness/`. Edit role instructions in `roles/`, never the generated `agents/` or `harness/*/agents/`; regenerate with `scripts/build-agents.sh` and run `scripts/check.sh` after source maintenance.

Library agent files are source templates, not proof of installation or usable runtime capabilities. Do not edit global agent/skill configuration without separate authorization.
