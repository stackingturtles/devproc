# Development process library

Reusable instructions for parent-led development with specialist agents. This is **not an application**: the walkthrough below creates nothing until you authorize work in a separate target project.

[Process and gates](process.md) · [Parent router](skills/development-process/SKILL.md) · [Agent harnesses](harnesses.md) · [Checkout instructions](AGENTS.md)

## Setup

Clone the library once. Its absolute path is the **process-root**. Keep its layout intact, and keep it separate from your **target/project-root** (for example `/work/my-product`).

```bash
git clone https://github.com/stackingturtles/devproc.git ~/code/devproc
```

### Claude Code

Add this checkout as a plugin marketplace, then install the `devproc` plugin:

```bash
claude plugin marketplace add ~/code/devproc
```

```bash
claude plugin install devproc@devproc
```

Restart Claude Code, then check:
- `/agents` lists `devproc:coder`, `devproc:infra`, `devproc:planner`, `devproc:researcher`, and `devproc:reviewer`.
- The skills appear as `devproc:<name>`.

Start a workflow from your target project with `/devproc:development-process`, giving the project-root, feature, and stage.

The installed plugin is a copy. After pulling library changes, refresh it and restart:

```bash
claude plugin marketplace update devproc
```

```bash
claude plugin update devproc@devproc
```

Remove any older standalone copies of these skills from `~/.claude/skills/` (for example `pr-code-review`) so the plugin's versions run. See [harnesses.md](harnesses.md#claude-code) for delegation, interviews, and target-project settings.

### Pi

Install the required extensions:

```bash
pi install npm:pi-web-access
```

```bash
pi install npm:pi-subagents
```

```bash
pi install npm:@juicesharp/rpiv-ask-user-question
```

```bash
pi install npm:@narumitw/pi-lsp
```

```bash
pi install npm:pi-hashline-edit-pro
```

Install the five role agents:

```bash
mkdir -p ~/.pi/agent/agents && cp ~/code/devproc/harness/pi/agents/*.md ~/.pi/agent/agents/
```

Reload Pi and check that the `coder`, `infra`, `planner`, `researcher`, and `reviewer` agents are discoverable and enabled. Repeat the copy after pulling library changes.

Pi does not discover the library's `skills/` folder automatically, so load the router explicitly:

> Read `~/code/devproc/skills/development-process/SKILL.md` and follow it as the parent router. Target project: `/work/my-product`. Confirm the stage and scope before acting.

See [harnesses.md](harnesses.md#pi) for provider and delegation details.

### Before delegated work

Check the exact discoverable/enabled agents, required skills, tools, and loaded providers. Research's web tools must be usable in the child; installed packages alone are insufficient. Missing capabilities block affected work, not permission to switch delegation mechanisms.

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

## License

Copyright (c) 2026 Stacking Turtles. Released under the [MIT License](LICENSE).

[create-verification-skill](skills/create-verification-skill/LICENSE) and [maintain-verification-skill](skills/maintain-verification-skill/LICENSE) are adapted from upstream work and keep their own MIT licenses.
