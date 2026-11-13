# 02 — Planning

## Use / Owner

Use to define a bounded increment or amend planned intent. PLANNER is the document writer; the parent relays interviews and user approvals. Do not route document authorship to the coder by default.

## Read / Inputs

Read [Planning](../../process.md#2-planning) in full, including changes to planned work, plus the shared contract and artifact policy required by the router. Load [grill-with-docs](../../skills/grill-with-docs/SKILL.md), its referenced skills, and [rate-userstories](../../skills/rate-userstories/SKILL.md) before use. Read existing target instructions and relevant sources when present; initial Planning requires neither an existing target `AGENTS.md` nor already-created feature documents.

## Execute

1. Confirm target/project-root, increment, scope, exclusions, and allowed source writes. Resolve absolute `PLANNING_DIR` from the brief, otherwise project instructions, otherwise the canonical default. Validate symlinks and record the three absolute document paths and access in the brief. Own only that increment's `specification.md`, `user-stories.md`, and `build-plan.md` there. External documents stay outside the checkout; never copy them into it or commit them. Extra ADR/glossary files require approval.
2. Interview through `grill-with-docs`, following the harness's parent-led or parent-relayed interview mechanism in [harnesses.md](../../harnesses.md). Where the parent conducts the rounds, PLANNER writes from the supplied decisions and returns remaining questions through the supervisor exchange before continuing affected work. Capture human intent, bounded modules, decisions, constraints, visuals as needed, and intended build/install/runtime outcomes. Agree measurement scope and coverage basis as required by the canonical stage; escalate unsupported regions or known debt.
3. Have the user review the specification. Derive LinearStories epics/stories, run `rate-userstories` over the complete set, and apply recommendations. User decisions resolve product tensions/contradictions; never invent approval.
4. Produce dependency-ordered build steps from reviewed stories. For amendments, change the specification first, regenerate/review derived documents, and keep all three aligned before affected implementation.

## Handoff / Stop

Return document paths, scope, review outcome, actual approvals, and unresolved questions in conversation. Stop for user review when requested; no automatic Setup or Coding. Before an artifact agreement, do not write runtime notes/reports without approval; the three authorized source documents are not extra reports.
