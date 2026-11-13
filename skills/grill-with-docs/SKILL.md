---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
disable-model-invocation: true
---

Load and apply the sibling `../grilling/SKILL.md` and `../domain-modeling/SKILL.md`
using the agent's supported skill mechanism or by reading those files directly.
Do not assume an editor-specific Skill tool exists.

For the development process, use the interview to produce the bounded
`PLANNING_DIR/specification.md`, including intent, scope, exclusions,
verification outcomes, and relevant visuals. Domain terminology and decisions
should inform that specification. Additional glossary/ADR source documents require
an agreed scope; they do not replace the specification. Follow the project's
external-artifact policy for any interview run notes or progress/review records.

Resolve `PLANNING_DIR` from the parent brief, otherwise project `AGENTS.md`,
otherwise the default in the [planning-location policy](../../process.md#planning-directory-planning_dir).
Use the canonical absolute paths recorded in the brief; only PLANNER writes the
three documents during authorized Planning. External documents remain outside the
checkout and must not be copied into or committed to it. Missing access goes
through the parent; this skill does not grant additional write permissions.
