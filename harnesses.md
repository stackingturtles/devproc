# Agent harnesses

[process.md](process.md), the [runbooks](runbooks/), the [skills](skills/), and the role bodies in [roles/](roles/) are harness-neutral. Everything that depends on a particular coding-agent harness lives here and under [harness/](harness/). Supported harnesses: [Pi](#pi) and [Claude Code](#claude-code).

## Capability contract

Every supported harness must give the parent and the five role agents:

| Capability | Used for |
| --- | --- |
| Delegation with fresh child context, resumable for a bounded ongoing task | Responsibility changes, independent review |
| Leaf children that cannot delegate further | Role boundaries |
| Strict per-role tool allowlists | Planner/reviewer/researcher boundaries |
| A supervisor channel from child to parent | Decisions, interviews, blockers |
| Structured user questions from the parent | Interviews, approvals |
| Web search and fetch in the researcher | Research |
| Explicit skill loading by absolute `SKILL.md` path | Every stage |
| File editing; language-server support where available | Setup, Coding |

A harness section below documents how each capability is provided. A capability the harness lacks is a disclosed blocker, never permission to improvise another mechanism.

## Pi

**Install.** Install globally: `pi-web-access`, `pi-subagents`, `@juicesharp/rpiv-ask-user-question`, `@narumitw/pi-lsp`, and `pi-hashline-edit-pro`. With separate authorization, install or update the generated agents from [harness/pi/agents/](harness/pi/agents/) into `~/.pi/agent/agents/`, reload Pi, and check the exact discoverable/enabled agents, required skills, tools, and loaded providers. Subagents must remain enabled whenever Pi is running.

**First use.** A plain `skills/` source directory is not discovered automatically. Load the router explicitly:

> Read `/absolute/process-root/skills/development-process/SKILL.md` and follow it as the parent router. Target project: `/work/my-product`. Confirm the stage and scope before acting.

If you register the router through supported Pi configuration, keep the bundled layout so that `../..` from the skill still resolves to the process-root.

| Capability | Pi mechanism |
| --- | --- |
| Delegation | Load the installed `pi-subagents` skill before multi-step workflows and follow its workflow rules |
| Supervisor channel | `contact_supervisor` (`need_decision`, `interview_request`) |
| User questions | `@juicesharp/rpiv-ask-user-question` |
| Web | Providers registering `web_search`, `fetch_content`, `get_search_content`, `source_check` (from `pi-web-access`) |
| Editing / LSP | `pi-hashline-edit-pro`, `@narumitw/pi-lsp` |
| Skill names | Exact names, for example `pr-code-review` |

**Provider and settings notes.**
- `inheritSkills: true` exposes a catalog, not executed instructions.
- Background children may use ambient providers. Foreground children need explicit `extensions`/`subagentOnlyExtensions` configuration.
- `acceptanceRole` controls acceptance inference, not sandboxing or permission.
- Missing capabilities block the affected work. They are never permission to switch delegation mechanisms.

## Claude Code

**Install.** This repository is also a Claude Code plugin (`devproc`) with its own one-plugin marketplace. With authorization, install it at user scope:

```bash
claude plugin marketplace add /absolute/process-root
claude plugin install devproc@devproc
```

The installed plugin is a cached copy, so after you edit the library run `claude plugin marketplace update devproc` and `claude plugin update devproc@devproc`, then restart. While maintaining the library, `claude --plugin-dir /absolute/process-root` loads the live checkout for one session instead.

The plugin provides the 11 skills under [skills/](skills/) and the five role agents generated into [agents/](agents/). Claude Code's plugin loader discovers agents only in the plugin's root `agents/` folder.

**First use.** In the target project, invoke `/devproc:development-process` and give the target project-root, feature, and stage. When the router skill loads, Claude Code shows its base directory; resolve process-root as `../..` from there. That is the cached plugin copy when the plugin is installed, or the checkout under `--plugin-dir`.

| Capability | Claude Code mechanism |
| --- | --- |
| Delegation | The built-in Agent tool with the plugin's role agent (namespaced, for example `devproc:coder`; confirm with `/agents`). A new Agent call gives fresh context. `SendMessage` to the same agent resumes a bounded ongoing task. A fork is exceptional. |
| Leaf children | Role agents get no Agent tool, and subagents cannot spawn subagents |
| Supervisor channel | **Stop and return.** A child cannot reach the parent mid-task, so it ends its turn with a `NEEDS_DECISION` section (numbered questions, recommended answers, blocked work). The parent asks the user and resumes the child with `SendMessage`, quoting the user's answers verbatim. |
| User questions | `AskUserQuestion` for short choices. Ordinary conversation for multi-question grilling rounds. |
| Web | `WebSearch`, `WebFetch`. Don't substitute `curl`. |
| Editing / LSP | Built-in `Edit`/`Write`. Optional code-intelligence (LSP) plugins for the project's languages. |
| Skill names | Plugin-namespaced, for example `devproc:pr-code-review`. This satisfies the process's exact-name requirement. |

**Interviews.** Children cannot interview the user. During Planning, the parent reads [grill-with-docs](skills/grill-with-docs/SKILL.md) and runs the grilling rounds with the user in the main session. A fresh `devproc:planner` then writes the three documents from the recorded decisions and returns any remaining questions as one `NEEDS_DECISION` round. The parent also relays mid-task decisions for the other roles this way.

**Skills marked `disable-model-invocation`** (`grill-me`, `grill-with-docs`, `create-verification-skill`, `maintain-verification-skill`) can only be invoked by the user as slash commands. The parent and children read their `SKILL.md` files directly, which the process already requires.

**Conflicting global copies.** Skills installed separately in `~/.claude/skills/` with the same names make it unclear which version runs. Older standalone copies of `pr-code-review` default their ledger to `docs/reviews/`, which this process forbids. Remove or update such copies with the user's authorization. Claude Code's built-in `/code-review` and `/simplify` are not substitutes for `pr-code-review` and `code-simplifier`.

**Target project setup** (CODER, during Setup, with approval for each file):
- Keep `AGENTS.md` canonical and add a one-line `CLAUDE.md` containing `@AGENTS.md`, so Claude Code loads the same instructions.
- In the project's `.claude/settings.json`:
  - Allow the agreed artifact root (as an absolute path).
  - Pre-allow the nonmutating Make gates.
  - Make commits and pushes prompt every time, so they always need explicit authorization.
  - Enable the plugin.

  For example:

  ```json
  {
    "permissions": {
      "additionalDirectories": ["/home/<user>/.local/state/agent-workflows/<project-key>"],
      "allow": ["Bash(make test)", "Bash(make lint)", "Bash(make static-analysis)", "Bash(make format-check)", "Bash(make build)"],
      "ask": ["Bash(git commit:*)", "Bash(git push:*)"]
    },
    "enabledPlugins": { "devproc@devproc": true }
  }
  ```

**Readiness preflight.**
- `/agents` lists the five `devproc:` role agents.
- The stage skills resolve as `devproc:<name>`.
- `WebSearch`/`WebFetch` are permitted for the researcher.
- The artifact root is an allowed directory.
- No conflicting global skill copies remain, or the user has accepted them.

## Maintaining both harnesses

- **Role instructions:** edit [roles/](roles/), never the generated agents. `roles/_shared.md` holds rules appended to every role, such as how to communicate with the user. Harness-specific frontmatter and notes live in `harness/<harness>/frontmatter/` and `harness/<harness>/notes/` (`_all.md` applies to every role; `<role>.md` adds role-specific notes). Regenerate with `scripts/build-agents.sh`. Pi output goes to `harness/pi/agents/`; Claude Code output goes to `agents/` (set by `harness/claude/output-dir`).
- **Harness-specific wording:** keep it in this file and `harness/`. The check flags harness tool and package names anywhere else.
- **Before committing:** run `scripts/check.sh`. It fails on stale generated agents, harness-specific terms in shared files, broken relative Markdown links, and an invalid plugin manifest (when the `claude` CLI is available).
- **Adding a harness:**
  1. Add `harness/<name>/frontmatter/<role>.yaml` for all five roles, plus `harness/<name>/notes/_all.md`.
  2. Add a section here covering every row of the capability contract.
  3. Add the harness's distinctive terms to the check's term list.
  4. Regenerate.
