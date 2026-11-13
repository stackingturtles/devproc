---
name: development-process
description: Route a parent-led development workflow through Research, Planning, Setup Tooling, Coding, Reviewing, and separately authorized Deployment. Use to select and load a bounded stage from this reusable process library, or distinguish library maintenance from target-project execution.
---

# Development-process router (parent only)

This is a router, not a new persona or permission to run six stages. For a source-maintenance request, edit only the requested library sources; do not start application work. For workflow execution, the parent owns routing, interviews, approvals, acceptance, and user-approved stop points. Confirm stage/feature ambiguity with the user; do not infer it from stale conversation.

## Resolve and load

1. Resolve symlinks to this skill's actual source directory, then resolve **process-root** as `../..` relative to that directory, preserving the library layout. Resolve all bundled links below from that source directory. Separately confirm the absolute **target/project-root**, feature, and authorized scope; do not treat process-root as the product checkout.
2. Locate headings in [process.md](../../process.md) with search, then read bounded ranges for [Overview](../../process.md#overview), [Shared roles and parent handoff contract](../../process.md#shared-roles-and-parent-handoff-contract), and [External artifacts and review records](../../process.md#external-artifacts-and-review-records). For work creating or consuming planning documents, also read the [planning-location policy](../../process.md#planning-directory-planning_dir). Anchors are navigation aids, not scoped read operations; do not use fixed fragile line numbers or load the whole manual by default. Missing required policy must be read or reported blocked, never replaced with remembered summaries.
3. Read the assigned canonical stage **in full**, including all relevant subsections and its transition/completion rules, plus its one thin runbook below. Load required subskills and specialized references only when needed for that task. The runbook cannot weaken or relocate a canonical gate.
4. Resolve target `AGENTS.md` and the current increment's absolute `PLANNING_DIR` under the [planning-location policy](../../process.md#planning-directory-planning_dir): parent brief, otherwise project instructions, otherwise the documented default. Resolve the fixed `specification.md`, `user-stories.md`, and `build-plan.md` paths canonically, including symlinks, and record them and access in the brief. Only PLANNER writes these during authorized Planning; external documents must never be copied into or committed to the checkout. Research needs no such files or completion gate. Initial Planning creates the three documents and does not require already-created docs or `AGENTS.md`; read existing applicable instructions when present. Setup bootstraps target `AGENTS.md` and tooling. Later stages use those current project inputs read-only. Missing access is a blocker, not permission to relocate inputs.

## Route only the approved work

| Stage | Owner and bounded responsibility | Load |
| --- | --- | --- |
| [Research](../../process.md#1-research) | RESEARCHER supplies evidence; no fixed deliverable/gate | [01](../../runbooks/stages/01-research.md) |
| [Planning](../../process.md#2-planning) | PLANNER is WRITER of the three aligned docs and specification-led amendments | [02](../../runbooks/stages/02-planning.md) |
| [Setup Tooling](../../process.md#3-setup-tooling) | CODER owns readiness; INFRA supports assigned infrastructure/CI slices | [03](../../runbooks/stages/03-setup-tooling.md) |
| [Coding](../../process.md#4-coding) | CODER implements approved stories and owns remediation | [04](../../runbooks/stages/04-coding.md) |
| [Reviewing](../../process.md#5-reviewing) | Independent REVIEWER checks bounded scope or all six ordered checks | [05](../../runbooks/stages/05-reviewing.md) |
| [Deployment](../../process.md#6-deployment) | INFRA/operator delivers only with separate target/action/artifact authority | [06](../../runbooks/stages/06-deployment.md) |

These names refer to role agents generated from [roles/](../../roles/) for each supported harness; edits here do not install them. Identify the running harness and follow its section of [harnesses.md](../../harnesses.md) for installation, delegation, the supervisor channel, user interviews, and skill/agent naming. Before authorized multi-step delegation, use that harness's documented delegation mechanism and preflight exact discoverable/enabled role names, usable named skill files, registered tools, loaded providers and model availability for each child, not merely installed packages. In particular, Research's web tools must be usable in the child. A missing required skill/provider, an undocumented harness, or a failed launch blocks the affected lane; do not invent a generic CLI or a delegation mechanism the harness section does not document.

Use one writer per checkout and one serial live driver. Start fresh child context at responsibility changes, especially reviewer independence. Resume the same worker only for a bounded coherent ongoing task. Fork is exceptional for genuinely needed history, not a token-saving default. Leaf roles do not delegate. Supply absolute process/runbook/project paths to global profiles; never rely on paths relative to their installed directory.

Preflight whether role restrictions are enforced by the harness or supplied as instructions; disclose limitations and block work that requires unavailable enforced isolation. For decisions and interviews, follow the harness's native messaging or documented stop-and-return exchange. In the latter case, obtain the user's answers in the parent session and resume the same child for its bounded task; a returned question is not task completion or permission to proceed.

## Task brief template

Keep briefs short; link exact source sections and preapproved evidence instead of pasting huge logs.

```text
Stage/mode + bounded goal/feature:
Process-root + canonical section + runbook (absolute paths):
Target project-root/cwd + applicable AGENTS path (or not-yet-created):
Planning inputs: resolved absolute PLANNING_DIR + specification.md,
  user-stories.md, build-plan.md paths; location source; authorized access
  (PLANNER-only writes during Planning); or not-yet-created/not-needed:
Allowed edits; prohibited side effects:
Required skills (exact names/files), tools/providers and preflight result:
Role restrictions: enforced controls versus instructions; required isolation:
Supervisor exchange: messaging recipient/reply mechanism or stop-and-return:
Candidate/base/range + included working-tree changes (when relevant):
Authority: user decisions/approvals and stop point:
Artifact permissions: approved root/absolute ARTIFACT_DIR, classes, access,
  retention/cleanup, ledger permission; default or approved alternate root;
  or no runtime writes approved:
Recipient + completion criteria + required commands/evidence:
```

Without an artifact agreement before Setup, no runtime artifact writes until approved; this does not block conversation or authorized source planning. Do not introduce mandatory handoff files, progress reports, or ledgers. Canonical review-ledger requirements still need approved external storage before that check can complete.

## Completion handoff

Return in conversation: scope/mode; changed source paths; exact candidate; actual commands/results and permitted evidence paths; completion criteria satisfied or blocked; residual risks and next required decision. For bounded review, mark other checks not-run/out-of-scope, never whole-stage signoff. Parent inspects actual outputs and canonical gates, not just runtime `ok`. Pause at the agreed stop point. Missing tools, failed checks, stale evidence, and unavailable approvals are not passes; full review readiness never authorizes deployment.
