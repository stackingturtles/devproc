# Development process library

Reusable instructions for parent-led development with specialist agents. This is **not an application**: the walkthrough below creates nothing until you authorize work in a separate target project.

[Process and gates](process.md) · [Parent router](skills/development-process/SKILL.md) · [Agent harnesses](harnesses.md) · [Checkout instructions](AGENTS.md)

## First use

1. Keep this library's layout intact. Identify its absolute **process-root** and a separate **target/project-root** (for example `/work/my-product`).
2. Follow your coding agent's section of [harnesses.md](harnesses.md) to load the router and, with separate authorization, install the five role agents. Supported harnesses are [Pi](harnesses.md#pi) and [Claude Code](harnesses.md#claude-code), which installs this checkout as the `devproc` plugin.
3. Before delegated work, check the exact discoverable/enabled agents, required skills, tools, and loaded providers. Research's web tools must be usable in the child; installed packages alone are insufficient. Missing capabilities block affected work, not permission to switch delegation mechanisms.

## Layout

| Path | Contents |
| --- | --- |
| [process.md](process.md), [runbooks/](runbooks/), [skills/](skills/) | Harness-neutral process, stage runbooks, and skills |
| [roles/](roles/) | Harness-neutral role instructions (source of the role agents) |
| [harness/](harness/), [harnesses.md](harnesses.md) | Per-harness frontmatter, notes, and documentation |
| [agents/](agents/) · [harness/pi/agents/](harness/pi/agents/) | Generated role agents for Claude Code · Pi (run `scripts/build-agents.sh`; do not edit) |
| [.claude-plugin/](.claude-plugin/) | Claude Code plugin and marketplace manifests |
| [scripts/](scripts/) | Agent generator and consistency check |

Research/conversation does not require deployment tooling or automatic installers. Setup later preflights the full canonical project environment; installations/global configuration always need explicit authorization.

## Walkthrough: account registration

Use these prompts one at a time, reviewing results before continuing. Scope examples are **illustrative, not product decisions**: email/password registration might be included; billing and social login might be excluded. Decide the actual requirements in Planning.

**1. Research (optional)**
> Explore account-registration approaches and tradeoffs. Return sourced options in conversation. Do not implement or write runtime artifacts without approval.

**2. Planning**
> Use PLANNER to interview me and define a bounded account-registration increment. Write the specification, derive and rate the stories, then build the ordered plan. Stop for my review; no Setup or Coding yet.

The three target-project documents are `docs/account-registration/specification.md`, `docs/account-registration/user-stories.md`, and `docs/account-registration/build-plan.md`.

To change intent later:
> Add email verification to the specification through Planning. Resolve decisions with me, regenerate and review the derived stories and build plan, and stop before affected implementation.

**3. Setup Tooling**
> Use CODER to prepare the approved target project, create/update its AGENTS.md and tooling, and agree external artifact permissions. Ask before installations or global changes. Report readiness/blockers; stop before Coding.

**4. Coding**
> Implement only the approved account-registration plan with CODER. Prove acceptance criteria with tests, simplify, pass Coding gates, and create/maintain and exercise the project verification skill. Stop for independent review.

**5. Reviewing**
> Use a fresh REVIEWER for all six ordered checks on the exact candidate. Route source fixes to CODER and refresh invalidated evidence. Report results; do not deploy.

**6. Deployment**
> After green review, request my explicit authorization for `<target>`, `<exact reviewed artifact/digest>`, applicable migrations, smoke checks, and recovery. Do not deploy until granted.

## Working model

The parent retains decisions and stop points, uses fresh children at responsibility changes, and loads only the assigned stage/runbook and needed skills. [Canonical policy](process.md#progressive-loading-and-routing) governs gates and transitions; handoffs stay conversational with preapproved external evidence, not unsolicited reports.
