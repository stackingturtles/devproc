# Static Analysers

A companion to [Development Process](process.md), describing recommended static-analysis tools and project-specific policies for TypeScript, Python, Rust, Go, and Ruby.

This is a selection guide, not a requirement to install every tool. During Setup Tooling, choose the tools appropriate to the project, configure their rules, and document their exact invocation in `AGENTS.md`. During Coding, run the selected checks after simplification, address findings, and rerun validation before handing work to Reviewing.

## Types of checks

- **Type and compiler checking** detects incompatible types and other language-level errors.
- **Linting and bug-pattern analysis** detects suspicious constructs, common mistakes, and violations of agreed conventions.
- **Security-focused source analysis** identifies potentially unsafe coding patterns and, where supported, unsafe data flows.
- **Project hygiene analysis** detects unused files, exports, and dependencies.
- **Dependency auditing** checks external packages against advisories and dependency policies. It complements source analysis but is a separate category; see [Dependency Vulnerability Checking](dependency-checking.md) for tools and recommended commands.

Formatting, tests, and code review remain necessary. A formatter is not a substitute for static analysis, and a clean scan does not prove correctness or security.

Commands below are examples, not commands verified against a particular project. Run tools through the project's selected package manager or environment, with pinned versions and appropriate configuration. `process.md` owns stage timing and gate policy; this guide does not move dependency auditing into Coding.

Route authorized build outputs, test/tool caches, logs, coverage, CRAP reports, and review records through the configured `ARTIFACT_DIR` beneath `~/.local/state/agent-workflows/<project-key>/<run-id>/`. Keep them outside the checkout, including after symlink resolution. Rule source and deliberately authored test fixtures remain repository deliverables; generated run evidence does not.

## TypeScript

- **[TypeScript compiler (`tsc`)](https://www.typescriptlang.org/tsconfig/noEmit.html)** — type checking without generating JavaScript: `tsc --noEmit`. Keep this check even when another tool handles transpilation.
- **[ESLint with typescript-eslint](https://typescript-eslint.io/getting-started/typed-linting/)** — bug-pattern analysis and project conventions. Enable type-aware rules to catch issues such as unhandled promises and unsafe operations: `eslint .`.
- **[Knip](https://knip.dev/)** — unused files, exports, and dependencies: `knip`. Configure framework integrations and entry points so intentionally reachable code is not incorrectly reported as unused.

**Recommended baseline:** TypeScript compiler checking plus ESLint with type-aware typescript-eslint rules. Add Knip for unused-code checks. 

## Python

- **[Ruff](https://docs.astral.sh/ruff/)** — fast linting for common mistakes, unused imports, suspicious constructs, and configurable quality rules: `ruff check .`. Formatting is a separate operation.
- **[Pyright](https://github.com/microsoft/pyright)** — static type checking with configurable strictness: `pyright`.
- **[Bandit](https://bandit.readthedocs.io/en/latest/)** — security-focused source analysis for common insecure coding patterns: `bandit -r <source-path>`.

**Recommended baseline:** Ruff plus one type checker plus Bandit. Start with **Ruff + Pyright + Bandit**.

## Rust

- **[Cargo check](https://doc.rust-lang.org/cargo/commands/cargo-check.html)** — compiler-based type, ownership, and borrowing checks without a full build: `cargo check --workspace --all-targets`. It skips final code generation and does not replace builds or tests.
- **[Clippy](https://github.com/rust-lang/rust-clippy)** — common mistakes, suspicious patterns, unnecessary complexity, and performance issues: `cargo clippy --workspace --all-targets -- -D warnings`. Select feature combinations and target platforms appropriate to the project. Adopt stricter lint groups selectively rather than enabling everything indiscriminately.
- **[cargo-geiger](https://github.com/geiger-rs/cargo-geiger)** — reports `unsafe` usage in the project and dependencies: `cargo geiger`. An optional review aid, not a vulnerability detector or proof of code safety.

**Recommended baseline:** Cargo check plus Clippy. Use cargo-geiger when tracking unsafe-code exposure is useful.

**Separate dependency checks:** [cargo-audit](https://github.com/rustsec/rustsec/tree/main/cargo-audit) checks RustSec advisories with `cargo audit`. [cargo-deny](https://github.com/EmbarkStudios/cargo-deny) adds license, dependency-source, and other dependency-policy checks with `cargo deny check`. Choose based on the desired policy and avoid unnecessary advisory-checking duplication.

## Go / Golang

- **[`go vet`](https://pkg.go.dev/cmd/vet)** — built-in checks for suspicious constructs and likely mistakes, such as incorrect format strings: `go vet ./...`.
- **[Staticcheck](https://staticcheck.dev/docs/)** — additional bug, performance, simplification, and style checks: `staticcheck ./...`. Its documentation recommends running it alongside `go vet`.
- **[gosec](https://github.com/securego/gosec)** — security-focused source analysis for insecure API usage and potentially unsafe patterns: `gosec ./...`.
- **[golangci-lint](https://golangci-lint.run/docs/linters/)** — a configurable runner for multiple analyzers, including `govet`, `staticcheck`, and `gosec`: `golangci-lint run`.

**Recommended baseline:** golangci-lint configured to run **govet + staticcheck + gosec**. 

**Separate vulnerability check:** [`govulncheck`](https://go.dev/doc/security/vuln/) checks known vulnerabilities and uses call analysis to identify relevant vulnerable functions: `govulncheck ./...`. It complements general source analysis.

## Ruby

Use the project's bundle where appropriate, for example `bundle exec rubocop`.

- **[RuboCop](https://github.com/rubocop/rubocop)** — baseline linting for style, suspicious code, and common bug patterns: `rubocop`.
- **[Brakeman](https://github.com/presidentbeef/brakeman)** — security-focused static analysis specifically for **Ruby on Rails applications**: `brakeman`. It is not a general-purpose scanner for arbitrary Ruby projects.

## Cross-language analysis with Semgrep

[Semgrep](https://semgrep.dev/docs/supported-languages) supports all five languages. It can supplement language-specific checks with security rules and project-specific policies.

Custom rules are especially useful for encoding decisions an agent might otherwise overlook: which APIs are approved, which architectural boundaries must be preserved, and which unsafe shortcuts are prohibited. They complement, rather than replace, the specification and `AGENTS.md`.

A policy is a project decision. A match may be a policy violation without proving an exploitable vulnerability. Select rules according to the product's actual architecture and risks rather than treating every possible rule as mandatory.

### Candidate custom policies

#### 1. Approved APIs and integration boundaries

Require application code to use approved wrappers for outbound HTTP, database access, subprocess execution, file storage, or payments. Ban direct use of the underlying libraries outside the adapter modules.

For example, application services might be prohibited from importing a payment SDK directly; only `integrations/billing/` may do so. This can help prevent agents from introducing integrations that are explicitly out of scope.

**Implementation:** import and call patterns with path-scoped exceptions. These checks can enforce recognizable boundaries, but aliases, dynamic imports, reflection, or indirect calls may require additional patterns or analysis.

#### 2. No insecure configuration shortcuts

Flag explicit settings that disable TLS verification, enable production debug mode, or turn off an agreed security control.

**Implementation:** targeted syntax patterns for the project's actual libraries and configuration formats. Distinguishing production from tests or local development requires explicit path/configuration conventions. A source match alone does not establish the deployed configuration.

#### 3. Restricted dynamic execution and shell access

Prohibit direct `eval` calls, dangerous deserialization APIs, and shell-enabled subprocess execution outside narrowly approved modules.

**Implementation:** simple API bans are good starting rules. Distinguishing trusted from untrusted input requires dataflow analysis. A blanket API restriction is a policy, not proof that every use is vulnerable.

#### 4. Untrusted input must not reach dangerous sinks

Identify request data flowing into SQL construction, shell commands, filesystem paths, or HTML output without the appropriate handling.

**Implementation:** taint rules defining the project's sources, sinks, and relevant sanitizers. Validation must be specific to the sink: SQL parameterization, path confinement, HTML escaping, and shell argument handling are not interchangeable. Cross-function and cross-file coverage depends on language and engine capabilities.

#### 5. Sensitive information must not enter logs

Flag obvious logging of passwords, access tokens, authorization headers, or entire request bodies. Require the approved redacting logger rather than direct logging in sensitive modules.

**Implementation:** syntactic rules for recognizable fields and logger calls; taint rules for more involved flows. Naming-based checks cannot establish that all sensitive data is protected, and a redaction helper is not automatically sufficient for every data type.

#### 6. Architecture and dependency direction

Prevent UI components from importing database modules, domain code from depending on framework adapters, or one module from reaching into another module's private implementation.

**Implementation:** path-scoped import rules. These catch declared code boundaries, not every runtime dependency or architectural defect. Dedicated dependency-graph tools may be more suitable for complex relationships.

#### 7. Migration away from deprecated APIs

Ban calls to replaced helpers, old SDK clients, or obsolete internal interfaces. Rule messages should name the replacement.

**Implementation:** explicit import and call patterns. This is a useful, low-ambiguity way to keep agents from reintroducing old patterns after a migration.

#### 8. Suspicious error-handling shortcuts

Flag project-specific shortcuts such as Rust `unwrap()` in request-handling modules or prohibited broad exception handlers in Python services.

**Implementation:** narrow patterns and path scopes. Prefer existing compiler or language-specific lint rules when they already cover the requirement. Avoid blanket bans that conflict with legitimate tests, initialization paths, or approved error handling.

#### 9. Focused or skipped tests

Flag committed `test.only`, `describe.only`, unconditional skips, or analogous framework-specific constructs that can hide missing test execution.

**Implementation:** patterns tailored to the selected test framework. Allow intentional skips only through an agreed review process. Detecting skips does not prove that every acceptance criterion has a meaningful test.

### Suggested starting policies

Start with a small, high-signal set:

1. Restrict direct access to sensitive SDKs and require approved adapters.
2. Reject explicit TLS-verification bypasses in application code.
3. Reject the project's prohibited dynamic-execution and shell APIs.
4. Prevent focused tests from being committed.
5. Prevent use of deprecated internal APIs.

Add taint-based policies after the project has concrete input sources, sinks, and security boundaries to model. Treat these policies as candidates until the user approves their scope and exceptions.

### Example custom rule

The following illustrates a Python project policy that prohibits direct use of `eval`. It is not a complete dynamic-execution detector, and it has not been executed or tested as part of writing this document.

```yaml
rules:
  - id: project-python-no-eval
    languages: [python]
    message: >-
      Direct eval is prohibited by project policy. Use a parser for the
      expected data format or an explicitly approved alternative.
    severity: ERROR
    pattern: eval(...)
```

An alias or an indirect equivalent may require a separate rule. The `ERROR` level expresses the policy's chosen severity; CI failure behavior must still be configured.

### Rule storage, testing, and execution

If Semgrep is selected during Setup Tooling, a recommended project layout is:

```text
.semgrep/
├── rules/
│   └── no-eval.yaml
└── tests/
    └── no-eval.py
```

Each custom rule should have positive examples that must match and negative examples that must not match, including approved exceptions. Semgrep's test annotations use `ruleid: <rule-id>` and `ok: <rule-id>` in comments immediately before the relevant line. Keep corresponding rule and fixture basenames and relative subdirectories aligned. Test rules before adopting or changing them.

Example commands, to verify against the pinned Semgrep version and configured fixture layout:

```sh
# Test expected matches and non-matches in rule fixtures.
semgrep scan --test --config .semgrep/rules/ .semgrep/tests/

# Run local project policies and return failure when findings are present.
semgrep scan --config .semgrep/rules/ --error --strict .
```

`semgrep scan` does not fail on findings by default; `--error` makes findings fail the command. `--strict` also treats relevant scan warnings/errors as failures. Do not treat parsing failures, timeouts, skipped relevant files, or unavailable analysis as a clean scan. Exclude rule fixtures from normal application scanning while retaining their explicit rule tests.

Document the selected rule set, scope, approved exceptions, and exact commands in `AGENTS.md`. Do not suppress rules, broaden ignore paths, or change CI gates merely to make a failing check pass. Exceptions require user approval and a reason. Do not automatically apply code rewrites as part of validation.

Semgrep's cross-file analysis and other advanced capabilities vary by language and product tier. A local scan using a custom rule directory does not automatically enable proprietary cross-file analysis. The current supported-language documentation lists cross-file dataflow for TypeScript, Python, and Go, but cross-function rather than cross-file dataflow for Ruby and Rust. Check the selected engine's coverage before relying on a rule to enforce a cross-module requirement.

### What Semgrep should not be asked to guarantee

Semgrep is not a reliable general-purpose mechanism for proving that:

- Every acceptance criterion has a meaningful passing test.
- Every endpoint enforces the correct authorization and tenant isolation.
- All duplication has been removed or the code follows DRY in every case.
- The implementation meets the specification or is free of logic bugs.
- An agent obtained permission before creating progress notes or review reports.

Use tests and review for behavioral guarantees, language-specific tools for checks they already implement well, and agent instructions plus permission controls for documentation rules. A CI file-path check can help flag disallowed artifacts, but permission itself is not a property Semgrep can infer from source code.

## Adoption checklist

During Setup Tooling:

- Select a baseline for the project's actual languages and frameworks.
- Pin tool versions and commit appropriate configuration.
- Define source paths, generated-code exclusions, feature/target coverage, and any approved suppressions.
- Test and approve custom policies before making them blocking checks.
- Document exact commands in `AGENTS.md` and use the same commands locally and in CI.
- Decide explicitly whether dependency audits and optional specialist tools are part of the required checks.

During Coding:

- Run configured checks after code simplification.
- Fix reported issues and rerun checks against the final code.
- Disclose blockers and incomplete coverage; do not claim checks passed when they did not run successfully.
- Report results in conversation. Required evidence follows the artifact policy approved during Setup; additional progress or review documentation needs permission and must use the approved external run folders under `~/.local/`, never the repository.

## Semgrep references

- [Supported languages and analysis capabilities](https://semgrep.dev/docs/supported-languages)
- [Rule syntax](https://semgrep.dev/docs/writing-rules/rule-syntax)
- [Taint analysis](https://semgrep.dev/docs/writing-rules/data-flow/taint-mode/overview)
- [Testing custom rules](https://semgrep.dev/docs/writing-rules/testing-rules)
- [CLI reference and exit behavior](https://semgrep.dev/docs/cli-reference)
