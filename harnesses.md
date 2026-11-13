# Agent harnesses

[process.md](process.md), the [runbooks](runbooks/), the [skills](skills/), and the role bodies in [roles/](roles/) are harness-neutral. Everything that depends on a particular coding-agent harness lives here and under [harness/](harness/). Supported harnesses: [Pi](#pi), [Claude Code](#claude-code), and [OpenAI Codex](#openai-codex).

## Capability contract

Every supported harness must give the parent and the five role agents:

| Capability | Used for |
| --- | --- |
| Delegation with fresh child context, resumable for a bounded ongoing task | Responsibility changes, independent review |
| Leaf children forbidden to delegate; remove spawning tools where supported | Role boundaries |
| Per-role tool restrictions where supported; disclosed instruction-based boundaries otherwise | Planner/reviewer/researcher boundaries |
| A supervisor exchange from child to parent: native messaging or documented stop-and-return | Decisions, interviews, blockers |
| User questions from the parent, structured when supported | Interviews, approvals |
| Web search and fetch in the researcher | Research |
| Explicit skill loading by absolute `SKILL.md` path | Every stage |
| File editing; language-server support where available | Setup, Coding |

A harness section below documents how each capability is provided and whether restrictions are enforced by the harness or supplied through instructions. Instructions do not create tool isolation or a sandbox. Work requiring enforced isolation is blocked if unavailable. Other missing required capabilities are disclosed blockers, never permission to improvise another mechanism.

## Project location access

All harnesses use the parent brief's resolved absolute `PLANNING_DIR` and approved per-run `ARTIFACT_DIR`. The [planning-location policy](process.md#planning-directory-planning_dir) keeps `<project-root>/docs/<feature-name>/` as the default; the [artifact policy](process.md#external-artifacts-and-review-records) keeps `~/.local/state/agent-workflows/<project-key>/<run-id>/` as the default and permits an approved alternate external root with the same subfolders. Record both paths and access in briefs and target `AGENTS.md` as appropriate; location selection alone grants no permission.

For settings that persist across runs, the artifact agreement may approve a stable absolute parent directory containing the per-run `ARTIFACT_DIR`s (the default project-level parent is `~/.local/state/agent-workflows/<project-key>/`). Record and validate that parent separately; do not grant a broader directory implicitly. Tools still receive the assigned per-run `ARTIFACT_DIR`, and outputs remain contained there. Access to the parent does not authorize modifying other runs.

Preflight access to external planning files for every relevant role. Only PLANNER writes them during authorized Planning; the other roles read them. Supply the required access through the harness's supported controls without silently broadening permissions. If read-only access is instruction-based rather than enforced, disclose that limitation; required enforced isolation remains a blocker. Never copy external planning files into the checkout as an access workaround. Keep them separate from artifact writes and cleanup.

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
  - Allow the approved absolute artifact parent directory containing the per-run `ARTIFACT_DIR`s, as described in [Project location access](#project-location-access). If only one run directory is approved, grant that directory instead. Grant required external `PLANNING_DIR` access separately, respecting the Planning-only writer boundary and disclosing instruction-based restrictions.
  - Pre-allow the nonmutating Make gates.
  - Make commits and pushes prompt every time, so they always need explicit authorization.
  - Enable the plugin.

  For example (replace the directory placeholder with the approved absolute artifact parent directory; this example does not grant access to external planning files):

  ```json
  {
    "permissions": {
      "additionalDirectories": ["/absolute/approved-artifact-root"],
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
- The approved artifact root and required planning reads/Planning-only writes are accessible within the agreed permissions.
- No conflicting global skill copies remain, or the user has accepted them.

## OpenAI Codex

**Install.** Use a current local Codex client supporting standalone custom agents. Follow [README setup](README.md#openai-codex) to copy the five generated TOML files from [harness/codex/agents/](harness/codex/agents/) into `~/.codex/agents/` (or `$CODEX_HOME/agents/` when customized), then start a new session. Inspect conflicts before replacing any existing file. Project-scoped installation into the target's `.codex/agents/` is an alternative requiring authorization for those target files. Do not install both copies without resolving overrides. No edits to `~/.codex/config.toml` are needed for standalone role discovery.

Codex identifies each role by the TOML `name`: `devproc_coder`, `devproc_infra`, `devproc_planner`, `devproc_researcher`, and `devproc_reviewer`. The files contain `name`, `description`, and `developer_instructions`; they inherit the parent's model and reasoning settings. Do not add an invented `tools` allowlist or child permission override. The [official custom-agent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents#custom-agents) describes the schema, supported feature reductions, and inheritance.

**First use and skills.** Load the router by its absolute checkout path, or link the skill directories as described in the README and select `$development-process`. Codex discovers repository skills in `.agents/skills/` and user skills in `~/.agents/skills/`, including symlinked folders; this library's plain `skills/` directory needs explicit loading or registration. Preserve the entire checkout, resolve symlinks before computing process-root, and supply absolute source paths in briefs. Check for duplicates in both project and user locations; Codex can display both copies of a skill with the same name. See [official skill discovery](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills).

| Capability | Codex mechanism |
| --- | --- |
| Delegation | Native subagent tools, selecting the exact `devproc_*` custom agent. Start a new child without forked history at responsibility changes; use the client's native follow-up/resumption tool for the same bounded task. Inspect the actual registered schemas; if this client cannot select custom roles or provide fresh context, the affected lane is blocked. Do not substitute `codex exec`, a generic worker, or shell-based orchestration. |
| Leaf children | Explicit instructions prohibit further delegation. Custom TOML does not establish a strict spawning-tool allowlist; do not claim the tool is absent. |
| Role tool boundaries | Instruction-based role/edit restrictions plus any supported capability reductions. All five roles inherit parent permissions, provider, and MCP servers; a read-only role instruction does not establish a separate read-only sandbox. |
| Supervisor exchange | Native child-to-parent messaging when exposed. For example, sessions exposing `collaboration.send_message` can send to the parent recipient supplied in the brief; the parent uses the available follow-up tool to deliver answers. Preflight the recipient, delivery, and reply mechanism. Otherwise use the stop-and-return exchange below. |
| User questions | The parent uses `request_user_input` or an equivalent question tool only when available and permitted in the current mode; otherwise ordinary conversation. Follow the tool's limits and use conversation for approvals where the question tool cannot request them. Children relay questions to the parent. |
| Web | Native web search and page retrieval (for example `web.run` / `web__run`), or an explicitly approved search/fetch provider. Preflight actual child access. Cached versus live search follows parent configuration; time-sensitive research needs a usable live source. Missing required search/fetch blocks research; no shell-fetch substitution. |
| Editing / LSP | Native patch/edit and shell tools within the brief and parent permissions; language-server support only when actually available. |
| Skill names | Exact skill names such as `pr-code-review`; always read the required files at the supplied absolute paths. Built-in `/review` is not the process's `pr-code-review` skill or six-check Reviewing stage. |

**Interviews and decisions.** The parent reads [grill-with-docs](skills/grill-with-docs/SKILL.md), runs the interview rounds with the user in the main session, and supplies the decisions to a fresh `devproc_planner`. The child writes the three aligned documents and relays any remaining frontier questions with recommendations. Native messaging is a coordination channel, not user approval: the child waits for answers before dependent work. If messaging or waiting for a reply is unavailable, the child stops and returns a `NEEDS_DECISION` section with numbered questions, recommended answers, and blocked work. The parent obtains the user's answers and resumes the same child for its bounded task, relaying answers verbatim. Never treat a returned question as completion, silence as consent, or a message acknowledgment as an answer.

**Target project setup** (CODER during Setup, within authorized file scope):

- Keep the target's `AGENTS.md` canonical; Codex reads it directly. Record the actual tools, process paths, `PLANNING_DIR` selection/access, approved `ARTIFACT_DIR`, artifact agreement, and any instruction-based isolation limitations.
- Configure sandbox and approval policy in the parent session. Child TOML cannot override `sandbox_mode`, `approval_policy`, `model_provider`, or `mcp_servers`. Do not broaden permissions to simulate per-role isolation. Configure any needed MCP provider in the parent only with authorization.
- For a CLI session using workspace-write, launch from the target and use `--add-dir /absolute/approved-artifact-root` for the approved writable artifact parent directory containing per-run `ARTIFACT_DIR`s, as described in [Project location access](#project-location-access). If only one run directory is approved, grant that directory instead. Tools still receive the current per-run `ARTIFACT_DIR`. Research also needs the process checkout readable. Do not add the process checkout as writable merely to read skills. App/IDE sessions must establish equivalent approved access through their available settings.
- Preflight reads of an external `PLANNING_DIR`; do not add it as writable merely for other roles to read it. If authorized Planning needs writable access, the parent must arrange it explicitly through supported session controls. Child permissions are inherited; these settings do not enforce distinct planning-file permissions per role. Stop if the required access or isolation is unavailable.
- Keep native subagents enabled; if configuration disables them, request authorization before changing it. Commit, push, installation, global configuration, and deployment still require explicit process authority regardless of sandbox permission.

**Readiness preflight.**

- Record the client/version and confirm all five exact custom roles are available for selection, not merely present as files. `/subagents` in the CLI inspects agent threads; it is not proof of installed custom-role discovery.
- Confirm fresh child context, native follow-up/resumption, and the chosen messaging or stop-and-return exchange. Supply absolute source paths and, for messaging, the parent recipient and reply mechanism in the brief.
- Read the stage-required skill files; resolve conflicting copies before relying on discovery.
- Verify search/page retrieval in the researcher and the required edit/check tools in other roles. A loaded provider in the parent alone is insufficient evidence of child usability.
- Verify parent permissions cover approved target/artifact access and external planning reads/Planning-only writes; disclose instruction-based role boundaries and block tasks requiring unavailable enforced isolation.

This is a local Codex integration. CLI, desktop app, and IDE extension must each pass their capability preflight; this does not configure hosted cloud execution. Library validation checks generated files, not live installation or runtime delegation. See [official subagent availability and permissions](https://learn.chatgpt.com/docs/agent-configuration/subagents).

## Maintaining the harnesses

- **Role instructions:** edit [roles/](roles/), never the generated agents. `roles/_shared.md` holds rules appended to every role, such as how to communicate with the user. Harness-specific frontmatter and notes live in `harness/<harness>/frontmatter/` and `harness/<harness>/notes/` (`_all.md` applies to every role; `<role>.md` adds role-specific notes). Regenerate with `scripts/build-agents.sh`. Pi output goes to `harness/pi/agents/`; Claude Code output goes to `agents/` (set by `harness/claude/output-dir`); Codex uses TOML metadata in `harness/codex/frontmatter/` and outputs `harness/codex/agents/devproc_<role>.toml`. Codex instructions use TOML literal multiline strings; the generator rejects embedded `'''` delimiters.
- **Harness-specific wording:** keep it in this file and `harness/`. The check flags harness tool and package names anywhere else.
- **Before committing:** run `scripts/check.sh` with Bash and Python 3.11+ (standard-library `tomllib`; no package installation needed). It fails on stale generated agents, invalid Codex TOML/required fields, harness-specific terms in shared files, broken relative Markdown links, and an invalid plugin manifest (when the `claude` CLI is available).
- **Adding a harness:**
  1. Add metadata for all five roles and `harness/<name>/notes/_all.md`. Markdown agents use `frontmatter/<role>.yaml`; Codex uses `frontmatter/<role>.toml`. Extend the generator/validator if the new harness uses another format.
  2. Add a section here covering every row of the capability contract.
  3. Add the harness's distinctive terms to the check's term list.
  4. Regenerate.
