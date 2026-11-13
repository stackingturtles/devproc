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

### OpenAI Codex

Install and sign in using the [official Codex CLI setup](https://learn.chatgpt.com/docs/codex/cli). Use a current local client with standalone custom-agent TOML support. For the desktop app or IDE extension, check that the same custom agents and delegation tools are available; these instructions do not configure hosted cloud tasks.

Copy the five generated role agents (review any overwrite prompts):

```bash
mkdir -p ~/.codex/agents
cp -i ~/code/devproc/harness/codex/agents/*.toml ~/.codex/agents/
```

These paths assume the default `CODEX_HOME` (`~/.codex`); use your configured directory if different. Repeat the copy after pulling library changes, updating only the files installed from this library. Start a new session and confirm the exact custom names: `devproc_coder`, `devproc_infra`, `devproc_planner`, `devproc_researcher`, and `devproc_reviewer`. Check for project-local overrides in the target's `.codex/agents/`.

Codex does not automatically discover this checkout's `skills/` directory. You can load the router directly:

> Read `~/code/devproc/skills/development-process/SKILL.md` and follow it as the parent router. Target project: `/work/my-product`. Use the Codex role agents for the approved stage. Confirm the stage and scope before acting.

For skill discovery, optionally link the bundled skill directories into `~/.agents/skills/`. This keeps their relative references in the library intact. Existing destinations, including broken symlinks, are skipped for manual review:

```bash
mkdir -p ~/.agents/skills
for skill in "$HOME/code/devproc/skills/"*; do
  [ -f "$skill/SKILL.md" ] || continue
  dest="$HOME/.agents/skills/${skill##*/}"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    printf 'Review existing skill: %s\n' "$dest"
  else
    ln -s "$skill" "$dest"
  fi
done
```

Start a new session and check `/skills`; select `$development-process` and give the target, feature, and stage. Resolve symlinks to the source checkout before resolving process paths. Skill links follow library updates; copied agent TOML files still need refreshing. Resolve duplicate skill names explicitly or supply the library's absolute source paths in the brief.

The parent conducts interviews and relays child questions. Native child-to-parent messaging is used when available; otherwise the child stops and returns questions for the parent to answer and resume. Codex role boundaries are instruction-based, without strict per-role tool allowlists or separate child sandboxes. Tasks requiring enforced isolation remain blocked if unavailable. See [harnesses.md](harnesses.md#openai-codex) for the full capability contract and preflight.

### Before delegated work

Check the exact discoverable/enabled agents, required skills, tools, and loaded providers. Research's web tools must be usable in the child; installed packages alone are insufficient. Missing capabilities block affected work, not permission to switch delegation mechanisms.

## Layout

| Path | Contents |
| --- | --- |
| [process.md](process.md), [runbooks/](runbooks/), [skills/](skills/) | Harness-neutral process, stage runbooks, and skills |
| [roles/](roles/) | Harness-neutral role instructions (source of the role agents) |
| [harness/](harness/), [harnesses.md](harnesses.md) | Per-harness frontmatter, notes, and documentation |
| [agents/](agents/) · [harness/pi/agents/](harness/pi/agents/) · [harness/codex/agents/](harness/codex/agents/) | Generated role agents for Claude Code · Pi · Codex (run `scripts/build-agents.sh`; do not edit) |
| [.claude-plugin/](.claude-plugin/) | Claude Code plugin and marketplace manifests |
| [scripts/](scripts/) | Agent generator and consistency check (Bash; Python 3.11+ for TOML validation) |

Research/conversation does not require deployment tooling or automatic installers. Setup later preflights the full canonical project environment; installations/global configuration always need explicit authorization.

## Project locations

The parent brief or target project's `AGENTS.md` can select locations without changing the library:

| Parameter | Default | Override |
| --- | --- | --- |
| `PLANNING_DIR` | `<project-root>/docs/<feature-name>/` | Absolute directory for one increment's `specification.md`, `user-stories.md`, and `build-plan.md` |
| `ARTIFACT_DIR` | `~/.local/state/agent-workflows/<project-key>/<run-id>/` | Absolute external run root approved in Setup's artifact agreement, with the same seven subfolders |

For example, a brief may supply `PLANNING_DIR=/approved/planning/account-registration` and `ARTIFACT_DIR=/approved/evidence/product-checkout/run-001`. These are example locations, not permission to create or access them. The parent records canonical absolute paths, including symlink resolution, and authorized access. A brief's planning selection takes precedence over the project setting, subject to applicable instructions and approvals.

Only PLANNER writes planning documents during authorized Planning; other roles read them. External planning documents stay canonical outside the checkout and must not be copied into or committed to it. Generated outputs stay inside the approved external `ARTIFACT_DIR`, separate from planning inputs. Defaults are unchanged when no override is supplied. See the [planning-location policy](process.md#planning-directory-planning_dir), [artifact agreement](process.md#external-artifacts-and-review-records), and [harness access notes](harnesses.md#project-location-access).

## Walkthrough: account registration

Use these prompts one at a time, reviewing results before continuing. Scope examples are **illustrative, not product decisions**: email/password registration might be included; billing and social login might be excluded. Decide the actual requirements in Planning.

**1. Research (optional)**
> Explore account-registration approaches and tradeoffs. Return sourced options in conversation. Do not implement or write runtime artifacts without approval.

**2. Planning**
> Use PLANNER to interview me and define a bounded account-registration increment. Write the specification, derive and rate the stories, then build the ordered plan. Stop for my review; no Setup or Coding yet.

With the default `PLANNING_DIR` for this example, the three target-project documents are `docs/account-registration/specification.md`, `docs/account-registration/user-stories.md`, and `docs/account-registration/build-plan.md`. If the brief supplies another planning directory, use its three canonical files instead.

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
