# Dependency Vulnerability Checking

A tooling companion to [Development Process](process.md) and [Static Analysers](static-analysers.md).

Dependency vulnerability checking compares the project's dependency versions with known security advisories. It complements source-code analysis, tests, and review; it does not replace them. Checks should cover direct and transitive dependencies, with clear boundaries for development tools, optional features, platforms, and deployed environments.

The recommendations below are based on official tool documentation. Commands are examples; no tools were installed or audits executed while preparing this document. Pin versions and verify behavior against the project's chosen environment before making checks mandatory.

## Recommended tools

| Language | Recommended tool | Example command | Primary input |
| --- | --- | --- | --- |
| TypeScript / JavaScript with npm | npm audit | `npm audit` | npm dependency tree and lockfile |
| Python | pip-audit | `python -m pip_audit --strict` | Installed project environment; other input modes are available |
| Python with uv | uv audit, where preview tooling is acceptable | `uv audit --locked` | Current `uv.lock` and project configuration |
| Rust | cargo-audit | `cargo audit` | `Cargo.lock` |
| Go / Golang | govulncheck | `govulncheck ./...` | Selected packages, module graph, and build configuration |
| Ruby | bundler-audit | `bundle-audit check --update` | `Gemfile.lock` |

Choose the input that represents the versions actually being built or deployed. An installed environment and a lockfile are not interchangeable: either can contain packages the other does not.

## TypeScript / JavaScript

### npm audit

[npm audit](https://docs.npmjs.com/cli/commands/npm-audit/) checks dependency information against the configured registry's advisory service. It reports vulnerable packages and relevant remediation information, including transitive dependency issues.

```sh
npm audit
```

- Keep `package-lock.json` current. npm requires a lockfile by default; bypassing it can cause the dependency tree to be resolved differently between runs.
- Audit development and build dependencies as well as runtime dependencies. A vulnerability in a build tool can matter even if the package is not shipped to production.
- If a separate production-only check is useful, `npm audit --omit=dev` narrows its scope. It is not a replacement for the broader development/build audit.
- Audit requests send dependency information to the configured registry. Check registry support and privacy requirements, particularly for private dependencies.

By default, findings cause a nonzero exit status. An explicitly approved threshold can change that behavior:

```sh
npm audit --audit-level=high
```

This example fails for high and critical findings, not lower-severity findings. It changes the failure threshold, **not** which findings are displayed. Do not silently adopt a weaker threshold to obtain a passing check.

`npm audit` reports findings without upgrading dependencies. **`npm audit fix` is a mutation command**: it runs installation machinery and can change the dependency tree and lockfile. Do not include it in the validation command; review proposed upgrades separately, especially anything requiring `--force`.

**Recommended baseline:** `npm audit` over the full intended dependency scope. Use package-manager-native equivalents or an explicitly supported scanner if the project uses a different lockfile format; do not assume npm audits a pnpm, Yarn, or Bun lockfile.

## Python

### pip-audit

[pip-audit](https://github.com/pypa/pip-audit#readme), maintained under the Python Packaging Authority, checks known vulnerabilities using PyPI's vulnerability service by default. OSV is also supported.

Audit the installed environment using that environment's interpreter:

```sh
python -m pip_audit --strict
```

This checks installed packages, not everything declared in an arbitrary project lockfile. Ensure that the environment includes the intended runtime, development, and optional dependencies, or run separate checks for the required environments.

For requirements-based projects:

```sh
python -m pip_audit --strict -r requirements.txt
```

This normally performs dependency resolution, including transitive dependencies. Unpinned requirements may resolve to versions different from those actually deployed. Prefer fully resolved, reproducible inputs.

When the requirements file already contains the complete dependency closure with exact versions, resolution can be disabled:

```sh
python -m pip_audit --strict --no-deps --disable-pip -r requirements.txt
```

This does not discover omitted transitive dependencies. Only use it when the input really is complete.

The tool also supports `python -m pip_audit --strict --locked .` for supported project lockfiles. Its documented project formats currently include `pyproject.toml` and `pylock.*.toml`; do not assume this command directly reads `uv.lock`, `poetry.lock`, or `Pipfile.lock`.

**Important limitations:**

- Requirements/project resolution may fetch distributions and invoke build machinery for metadata. The tool's security model says to treat auditing such inputs as effectively equivalent to installing them; do not run it on untrusted inputs as though it were a harmless text scan.
- Findings return nonzero. `--strict` also fails when dependency collection fails; inspect skipped-package messages and other diagnostics rather than treating incomplete coverage as clean.
- Automatic upgrades require the separate `--fix` option. Leave it out of validation commands.

### uv audit

For uv-managed projects, the current official documentation includes [`uv audit`](https://docs.astral.sh/uv/reference/cli/#uv-audit):

```sh
uv audit --locked
```

It checks project dependencies against OSV by default and includes all extras and dependency groups by default. It also checks adverse package statuses such as deprecation and quarantine. It audits the project dependency set, not an inventory of packages actually installed in `.venv`.

The command remains a [preview feature](https://docs.astral.sh/uv/concepts/preview/#audit-command). Pin and verify a version that supports it before adopting it in CI.

Use `--locked` to require an existing, current lockfile without rewriting it. Plain `uv audit` can create or update the lockfile during resolution. `--frozen` is another option when deliberately checking the existing lock without freshness validation; that is a different guarantee from `--locked`.

**Recommended baseline:** pip-audit for general Python environments and requirements. For uv projects, consider `uv audit --locked` when preview tooling is acceptable; otherwise use a verified lock-aware alternative or audit a synchronized project environment with pip-audit. Do not mistake an unrelated global Python environment for the project's dependencies.

## Rust

### cargo-audit

[cargo-audit](https://github.com/rustsec/rustsec/tree/main/cargo-audit) checks locked crate versions against the RustSec Advisory Database:

```sh
cargo audit
```

- Audit the `Cargo.lock` used by the relevant workspace/build. The lockfile records direct and transitive crate versions.
- Require the intended lockfile to exist before validation. Current cargo-audit behavior can generate a missing lockfile through Cargo; auditing should not silently resolve a new dependency set.
- Refresh advisory data according to the project's policy. Cached or offline data can become stale.
- Review warnings such as unmaintained dependencies separately from vulnerability findings; configure which warning categories block completion.
- Version matches do not establish that vulnerable code is reachable. Platform and feature applicability may require investigation.

For lockfile-only auditing of an untrusted project, the official guidance is to run from outside that project and pass its lockfile explicitly, rather than invoking Cargo in the untrusted project directory:

```sh
cargo audit --file /path/to/project/Cargo.lock
```

The normal audit reports findings without applying dependency upgrades. Keep `cargo audit fix` separate from validation.

### cargo-deny as a broader policy option

[cargo-deny](https://embarkstudios.github.io/cargo-deny/checks/advisories/index.html) can perform advisory checks:

```sh
cargo deny check advisories
```

Its broader `cargo deny check` workflow can also enforce license, source, and dependency policies. Those are useful but are not all vulnerability checks. Select the desired policies deliberately and avoid redundant advisory gates unless they add useful coverage.

**Recommended baseline:** cargo-audit; choose cargo-deny when broader dependency governance is needed.

## Go / Golang

### govulncheck

[govulncheck](https://go.dev/doc/security/vuln/) uses the Go Vulnerability Database and static analysis to identify known vulnerabilities that may affect the selected program:

```sh
govulncheck ./...
```

Unlike a simple package-version audit, its default source analysis uses call information to identify vulnerable symbols reachable from the selected packages. This provides useful prioritization, but it is not proof of runtime exploitability or absence of risk.

- Run from the appropriate module directory and cover every relevant module in a multi-module repository.
- Use the intended Go toolchain, build tags, and platform configuration. Different build configurations can have different vulnerability exposure.
- Include test code where required using the documented `-test` option; do not assume the default scan covers all test dependencies.
- The tool can report standard-library vulnerabilities as well as module vulnerabilities, so remediation may require updating Go itself.
- Reflection and other analysis limitations can hide reachable behavior.

For a broader module-level inventory without call-based narrowing, the tool also supports:

```sh
govulncheck -scan=module
```

This mode does not accept package patterns. Choose whether the project requires a module-level advisory gate, a symbol-reachability gate, or both; their results represent different policies.

**CI caveat:** use the ordinary text-output command for a straightforward exit-status gate. The [command documentation](https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck) states that JSON, SARIF, and OpenVEX output modes exit successfully regardless of detected findings. If using those formats, explicitly evaluate the findings rather than relying on the exit code alone.

**Recommended baseline:** govulncheck source analysis for the relevant build configurations, with an explicit decision on broader module-level checking.

## Ruby

### bundler-audit

[bundler-audit](https://github.com/rubysec/bundler-audit#readme) checks gem versions in `Gemfile.lock` against RubySec's `ruby-advisory-db`, including transitive gems. It also detects insecure gem sources.

```sh
bundle-audit check --update
```

The gem is named `bundler-audit`; its documented executable is `bundle-audit`. Use the project's selected execution environment, such as `bundle exec bundle-audit check --update` when the tool is included in the project bundle.

- `--update` refreshes the advisory database, **not** the project's gems or lockfile.
- This checks locked gem versions, not every gem installed on the host.
- Findings and operational failures both produce unsuccessful checks; distinguish vulnerable dependencies from missing lockfiles or failed advisory-database updates.
- Cached-database checks are possible, but the database must be available and sufficiently fresh. Disabling updates alone does not guarantee offline operation when the database is missing.
- It does not automatically upgrade affected gems.

**Recommended baseline:** `bundle-audit check --update` against the project's current lockfile. This applies to Ruby generally, not only Rails. Brakeman remains a separate Rails source-code analyzer.

## Optional cross-language checking

[OSV-Scanner](https://google.github.io/osv-scanner/) provides a common scanner across these ecosystems. Its [supported inputs](https://google.github.io/osv-scanner/supported-languages-and-lockfiles/) include npm and other JavaScript lockfiles, Python lockfiles including `uv.lock`, `Cargo.lock`, `go.mod`, and `Gemfile.lock`.

An example source scan with the current CLI is:

```sh
osv-scanner scan source -r .
```

It can be useful for polyglot repositories or a consistent repository-wide inventory. Prefer resolved lockfiles where possible, verify the supported format and transitive coverage, and do not assume all ecosystems receive identical reachability analysis. A broad OSV scan is not equivalent to govulncheck's Go source-level analysis.

## Process and failure policy

### Setup Tooling

- Select the dependency checker for each ecosystem in the product.
- Pin tool versions and document installation, exact commands, inputs, and expected exit behavior in `AGENTS.md`.
- Cover all relevant workspaces, lockfiles, optional groups, build tools, and target configurations.
- Define advisory-database freshness, network/privacy requirements, and any approved severity thresholds.
- Keep dependency scans separate from mutation commands and from license/source-policy checks.

### Reviewing and release readiness

`process.md` owns stage timing: Setup configures the checker, and Reviewing runs `make dependency-audit` on the final candidate. Dependency auditing is not part of Coding's completion gate. Dependency fixes return to Coding for tested remediation; Reviewing then repeats the audit and any invalidated checks against the resulting candidate.

Store authorized audit logs, machine reports, and review records only in the standard subfolders of the approved absolute `ARTIFACT_DIR`, never in the repository. Validate canonical destinations, including symlinks, inside that root and outside the checkout. Both default and alternate roots and retention follow the Setup artifact policy. Do not introduce automatic upgrade commands into the audit target.

Advisories change even when code does not. A scheduled CI check between releases is useful in addition to change-triggered checks.

**Recommended gate:** no unresolved findings within the approved failure policy, and no incomplete or failed audits. Distinguish:

1. **A vulnerability finding** — investigate applicability and remediate.
2. **A tool, network, or database failure** — the audit is incomplete, not clean.
3. **A scoped or filtered result** — only the declared scope has been checked.

Do not suppress advisories, exclude dependencies, weaken thresholds, or accept risk without user approval. An approved exception should identify the advisory and affected dependency, rationale, owner, and expiry/review date in the user-approved external review record or issue tracker. Tool-enforced suppression configuration may be source-controlled only when explicitly approved; do not create repository-local exception reports.

Updates should be the smallest appropriate remediation, with compatibility and regression tests. Do not run blanket automatic-fix commands or force breaking upgrades merely to make an audit pass.

Report findings and validation results in conversation. Required audit records follow the artifact policy approved during Setup; additional progress or review documentation needs permission and must remain outside the repository under the approved `~/.local/` run folders.

## Limits

A clean dependency audit means no matching known findings were reported for the checked inputs under the configured policy. It does not prove the product is secure, establish exploitability, or comprehensively detect malicious packages, private unpublished vulnerabilities, operating-system packages, native libraries, containers, or deployed-environment drift. Add ecosystem, image, or system-package checks where the product needs them.
