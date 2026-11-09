---
name: create-verification-skill
description: Generate and prove a project-local verification skill and maintained feature map for real user-facing behavior across languages and platforms. Use during Coding when the project has no verification skill; existing skills use maintain-verification-skill.
disable-model-invocation: true
license: MIT
metadata:
  upstream: https://github.com/cursor/plugins/tree/6b0300214a09fd6029cfb7077043125758cd1fd2/pstack/skills/create-verification-skill
  upstream-revision: 6b0300214a09fd6029cfb7077043125758cd1fd2
---

# Create a verification skill

Create `skills/verify-<project>/SKILL.md` and its maintained `features/` map during
Coding. Write for the next agent, which will read the instructions cold. This is a
portable adaptation of the upstream pstack skill; its MIT notice is in `LICENSE`.
It does not require the surrounding plugin or its editor.

Example invocation where the skill is configured:

```text
/skill:create-verification-skill
```

## 1. Establish scope, authority, and output paths

Read `AGENTS.md`, the relevant `docs/<feature-name>/specification.md`,
`user-stories.md`, and `build-plan.md`, plus build/test configuration. Requirements
and acceptance criteria define expected behavior; current code alone does not.
Confirm the project identity, delivery environment, approved verification scope,
and source changes the task permits.

Locate existing verification skills first. If one applies, use
`maintain-verification-skill` instead. If several apply, ask which to maintain.
Do not overwrite an existing skill or make a second authoritative feature map.

Source deliverables belong in the project:

```text
skills/verify-<project>/
├── SKILL.md
├── features/
│   ├── README.md
│   └── <feature-name>.md
└── scripts/                  # only if reusable helpers are needed
```

Run outputs do not belong there. Obtain the approved absolute `ARTIFACT_DIR`:

```text
~/.local/state/agent-workflows/<project-key>/<run-id>/
├── build/
├── verification/
│   ├── evidence/
│   └── logs/
└── scratch/
```

Use a checkout-distinguishing project key and unique run ID. Validate resolved
paths against the approved root and outside the checkout, including symlinks.
Route binaries, screenshots, traces, logs, tool caches, isolated application data,
and temporary HOME/profile directories beneath this run directory. Follow the
artifact permissions and retention approved during Setup; ask before adding
unapproved report classes. Never use repository-local evidence folders or arbitrary
`/tmp` paths. Cleanup may remove owned scratch state, never retained evidence.

Creation authorizes only the requested source deliverables and approved local
verification. Do not install dependencies, access production or personal sessions,
use credentials, perform external side effects, commit, push, or open a PR without
separate authority. Missing runtime/harness prerequisites are blockers, not an
instruction to install or bypass them automatically.

## 2. Interview the repository

Answer from the repository; ask the user only what cannot be observed safely:

- **Surface:** what does the user touch—web UI, CLI/TUI, desktop, API, mobile,
  library? Identify primary and secondary surfaces and the required entry points.
- **Run:** use the documented Make targets and build/start commands. Record ports,
  configuration, migrations, fixture data, authentication, and readiness signals.
  Builds must honor external output routing.
- **Drive:** prefer existing project harnesses. Otherwise select a suitable
  browser/CDP, PTY, HTTP, or library-consumer harness. These are options, not
  dependencies this skill installs.
- **Observe:** identify action/result proof, exit status, screenshots/transcripts,
  response bodies, stored data, and prohibited side effects.
- **Isolate:** define owned processes, ports, data/profile directories, synthetic
  credentials, and whether concurrent instances are safe. Do not double-drive a
  shared or personal instance.

If the required build or launch is broken, disclose the exact failure and return
product remediation to the authorized Coding workflow. Do not generate fictional
working commands or weaken expected behavior. Verification scaffolding must stay
in owned external scratch state, be explicit, and never conceal a real missing
installation/runtime requirement.

## 3. Generate the verification skill

Write frontmatter with `name: verify-<project>` and a routing description naming
the product, surfaces, and intended use. Preserve required upstream license notices
when copying substantial template content. Use local skill loading or explicit
file loading; a source file under `skills/` is not automatically registered by
every harness. Do not introduce editor-specific tools or paths.

Include grounded, executable instructions, with no unknown command presented as
verified:

- **Scope and contract:** relevant requirements, environments, feature-map path,
  full versus targeted coverage, and expected outcomes.
- **Launch:** exact external-output build and launch commands; readiness must mean
  usable, including required initialization. Record teardown. Short-lived CLIs may
  need a fresh isolated session per journey rather than a persistent server.
- **Doctor:** read-only checks for ownership, expected build/version, endpoint,
  configuration, authentication, and usable fixture state. Run before driving and
  after surprising behavior; a healthy process alone may not imply healthy UI state.
- **Drive:** real selectors, commands, and routes. Prefer stable accessible handles
  over screen coordinates or tab order. Never use internal setters or test-only
  shortcuts as proof of the real user path.
- **Evidence:** capture the action and resulting state, plus required side effects
  and effects that must not occur. Put everything under `ARTIFACT_DIR/verification/`.
  Existing external-system boundaries may use approved substitutes; state the limit.
  Observe what dry-run/test modes actually skip rather than trusting their names.
- **Cleanup:** stop only processes the run owns; never kill by process name.
  Remove owned fixture/scratch state and confirm evidence survives cleanup.
- **Helpers:** document every owned helper's invocation and dependencies; executable
  helpers must have the right file mode. Do not add unnecessary harness layers.

## 4. Seed the maintained feature map

Read the bundled `references/feature-map-example/README.md`, `create-note.md`, and
`search.md`. They are illustrative Notes fixtures, not tools or an app to install.

Write `skills/verify-<project>/features/README.md` with shared preconditions,
conventions, coverage limits, and links. Add one file per required user-facing
feature; a useful seed may start with 3–5, but explicitly identify unmapped scope.
Do not claim complete product coverage from a partial seed. Prioritize the current
iteration's required features and link to their stories where helpful.

Each feature file has an H1, a user-visible description, and exactly these four H2s:

1. `Sub-features` — short stable IDs and behaviors.
2. `How to get to it (user POV)` — all supported entry points in scope.
3. `Driving it with <harness>` — starts with `Preconditions:` and pairs concrete
   actions/commands with observable expected results.
4. `Gotchas` — prerequisites and traps that can invalidate a run.

Keep implementation internals out of the user-facing recipes. A journey requiring
missing seed state is blocked; record the prerequisite, do not weaken the journey.
A convenient entry point does not prove other mapped entry points work.

## 5. Prove creation and hand off

Execute the generated instructions: launch, doctor, drive at least one mapped
feature through the real user boundary, capture action/result evidence, and clean
up. Check that evidence remains at the named external path after cleanup. Re-drive
changed harness instructions and clean owned resources after failures too.

A never-executed generated skill is a draft, not a completed deliverable. A
one-feature proof validates the harness, not all mapped behavior. If a stand-in
was used for a required target, identify what it supplies and what remains
unverified on the real target. Do not present blockers as PASS.

Report source files changed, the feature proved, exact commands, evidence paths,
coverage limits, and blockers in conversation. Additional narrative reports require
approval. Reviewing must independently assess relevance and run required journeys;
creation does not replace that review. Future Coding iterations use
`maintain-verification-skill` to keep the skill and map current.
