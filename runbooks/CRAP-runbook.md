# CRAP Runbook

Use **Change Risk Anti-Patterns (CRAP)** to identify functions that combine complexity with weak automated-test coverage. Use the results to select bounded testing and refactoring work—not to grade developers, certify correctness, or authorize rewrites.

This runbook has two parts:

1. **Language-independent operation:** how to collect, interpret, compare, and act on measurements.
2. **Language-specific implementation:** how to build or adopt tools that implement that workflow for a project's languages.

The command names below are a proposed common interface to implement during Setup Tooling. They are not a claim that every project, or this documentation folder, already has a CRAP collector. A historical TypeScript implementation is retained as a reference at the end.

> **Three rules:** score individual functions; interpret coverage within a fixed, explicit measurement profile; protect intended behavior before substantial restructuring.

# Part I — Language-independent runbook

## 1. Place CRAP in the development process

CRAP is a quality diagnostic, not a replacement for tests, linters, static analysis, dependency auditing, or runtime verification. When used with this folder's `process.md`, it is a required Reviewing check and every eligible function in the approved scope must score strictly `<30`. That process policy takes precedence over the diagnostic hotspot definition and optional baseline ratchet explained below.

- **Planning/Setup Tooling:** agree the production measurement scope and known debt early, implement the language adapters, pin tools, test the collector, and document the Makefile interface and strict `<30` gate in `AGENTS.md`. Diagnostic report-only collection or a ratchet may aid adoption, but neither substitutes for the process's completion gate. Resolve unsupported measurement regions or out-of-scope debt before Coding.
- **Coding:** use hotspot information to select requirements-based tests and bounded simplification. Recollect after relevant changes; old coverage cannot describe changed source.
- **Reviewing:** validate the candidate measurement, enforce the configured process gate, and inspect any baseline comparison. Review the affected responsibility, not just the score.
- **Deployment:** CRAP does not establish release readiness. Follow the project's separate functional and deployment checks.

Use the artifact policy approved during Setup for CRAP reports, coverage, build outputs, test caches, logs, and scratch state. All belong beneath the approved absolute `ARTIFACT_DIR`, using the default or an approved alternate run root. Validate canonical destinations inside that root and outside the checkout after resolving symlinks. The policy can authorize required outputs across runs; extra narrative reports still need permission. Report conclusions in conversation, and retain CI evidence only in an explicitly approved external store, never in committed project folders.

## 2. Prerequisites and common commands

Before collecting:

- Read the specification, user stories, and build plan from the brief's resolved `PLANNING_DIR` read-only, plus `AGENTS.md` and the project's CRAP profile. Never copy external planning documents into or commit them to the checkout.
- Confirm that the collector and its language adapters exist and their regression tests pass.
- Use the authorized, pinned runtime, analysis tools, and dependency environment. Quality commands must not install missing dependencies or upgrade tools automatically.
- Keep repository inputs stable throughout collection. Dirty work may be measured if recorded accurately; concurrent edits invalidate the run. Prefer an isolated, stable checkout for trusted baselines.
- Obtain approval for execution and artifact storage. Coverage runs execute project tests and potentially build scripts or subprocesses. A synthetic HOME and filtered environment are useful isolation, but are not a network or OS sandbox. Do not forward personal credentials or assume permission to access remote services.

Run commands from the target project's root. The project should expose:

| Command | Contract |
| --- | --- |
| `make quality-crap-test` | Test adapters, scoring, joins, validation, reporting, and comparison. Include a real coverage-provider fixture. This is not repository-wide coverage collection. |
| `make quality-crap [OUTPUT=<new-external-directory>] [BASELINE=<trusted-report>]` | Run the fixed test/coverage profile, validate inputs, compute per-function scores, and optionally compare against a baseline. |
| `make quality-crap-report RUN=<existing-run> [BASELINE=<trusted-report>]` | Validate an existing collection and regenerate reports without rerunning tests. Reject stale or incompatible inputs. |

Use the approved absolute `ARTIFACT_DIR` for the current run. The collector may choose a new `crap/` measurement directory beneath that run root when `OUTPUT` is omitted; it must not fall back to `/tmp`. An explicit destination must be a **new directory beneath the approved project/run area**, outside the checkout after symlink resolution, with an existing parent. Never overwrite another run or accept a symlink escape.

After execution and artifact storage are authorized, an illustrative collection is:

```sh
# Use the absolute run root approved during Setup and validated before execution.
: "${ARTIFACT_DIR:?Supply the approved absolute ARTIFACT_DIR}"

make quality-crap-test ARTIFACT_DIR="$ARTIFACT_DIR"
RUN="$ARTIFACT_DIR/crap"
make quality-crap ARTIFACT_DIR="$ARTIFACT_DIR" OUTPUT="$RUN"

# Only while the original collection inputs are still valid:
make quality-crap-report ARTIFACT_DIR="$ARTIFACT_DIR" RUN="$RUN"
```

Do not pre-create `"$RUN"`. These commands are the common interface; the project implementation determines the underlying language tools. Do not add ad hoc test filters, coverage exclusions, or threshold overrides to make a measurement pass.

## 3. Understand the score and its limits

For each function:

```text
C = cyclomatic complexity, at least 1
v = the profile's declared coverage fraction, from 0 to 1

CRAP = C² × (1 − v)³ + C
hotspot ⇔ CRAP > 30
```

This runbook uses a strict **greater-than-30** hotspot threshold, with no minimum function-length filter. Any different project policy must be explicit, versioned, and reflected in baseline compatibility.

| Complexity | Coverage | CRAP | Hotspot? |
| ---: | ---: | ---: | --- |
| 1 | 100% | 1 | No |
| 5 | 0% | 30 | No: exactly 30 is not above the threshold |
| 6 | 0% | 42 | Yes |
| 10 | 0% | 110 | Yes |
| 10 | 50% | 22.5 | No |
| 30 | 100% | 30 | No |
| 40 | 100% | 40 | Yes: more execution coverage cannot remove it |

At zero coverage, the score is `C² + C`. At full coverage, it is `C`. Classification and comparison use unrounded numbers: a displayed `30.00` can still exceed 30.

**Coverage semantics matter.** The original proposal specifies basis-path coverage. Many practical implementations use branch outcomes, line coverage, or statement coverage instead. Those are declared adaptations, not interchangeable measurements. Record the basis prominently and do not compare scores across incompatible profiles or languages as a universal ranking.

Coverage records execution, not assertion strength. It does not prove correct authorization, all condition combinations, meaningful acceptance tests, or absence of defects. A low CRAP score does not waive any acceptance criterion's test requirement.

**Background correction:** the NDepend article's example gives 37 for complexity 6 and zero coverage. Its stated formula gives `6² + 6 = 42`. Its described warning also includes a method-length filter; this runbook does not inherit that filter.

## 4. Collect and validate a measurement

1. **Select the approved profile.** Fix production source scope, test selection, coverage basis, compiler/build settings, concurrency, environment, exclusions, and skip policy.
2. **Inventory functions independently of test execution.** Include eligible functions in unimported or unexecuted production files. Define how methods, constructors, closures, accessors, nested functions, generated code, and compiler-generated entities are handled.
3. **Collect fresh coverage and test results.** Record the revision, dirty state, input fingerprints, tools, platform, test population, and skipped-test identities. Keep coverage of subprocesses, containers, native extensions, or other runtimes explicit.
4. **Join complexity and coverage at function level.** Use source identity, lexical ownership, and locations or provider identifiers. Do not apply a file's coverage percentage to every function in that file.
5. **Validate before scoring.** Reject failed or unexpectedly empty test runs, stale inputs, ambiguous joins, missing required mappings, invalid counters, incompatible tools, and interrupted collections. Do not silently convert missing data into zero or full coverage.
6. **Generate authorized results.** Mark unsupported/unmeasured regions explicitly; they cannot contribute to a claimed complete quality gate. Sort full-precision results deterministically.

A declared fallback may be used when the chosen provider genuinely has no branch outcomes for a function. For example, a profile may use a measured function-invocation counter in that case. Record it as `function-hit-fallback`, not branch coverage. Missing instrumentation is not evidence that the function is branchless, and an executed line is not automatically a reliable invocation counter.

If a language cannot provide the chosen coverage basis reliably, use a separately named profile or do not score that region. Do not invent branch coverage from line or statement totals.

## 5. Inspect and handle evidence

A recommended authorized run directory contains:

| Artifact | Purpose |
| --- | --- |
| `manifest.json` | Status, revision/dirty state, input and source hashes, profile/policy, toolchain/platform details, and raw-artifact hashes. |
| Test log and structured test results | Diagnose execution, failures, and skipped/pending tests. |
| `coverage/` | Raw provider output and source maps or equivalent mapping evidence. |
| `report.json` | Full-precision function inventory, measurement provenance, rollups, and optional comparison results. |
| `functions.csv` | Full inventory for sorting/filtering. |
| `summary.md` | Optional, explicitly authorized human summary; not a substitute for the complete inventory. |

Inspect function identity/location, complexity, coverage basis, covered/total counts where available, score, and comparison status together. Repository/file rollups should summarize function counts, hotspots, and maxima—not substitute file-level or repository-average inputs into the formula.

Raw logs and coverage may contain sensitive fixture data or temporary paths. Apply the approved permissions and retention to the external run directory; an unpredictable directory name is not an access-control policy. Retain approved CI evidence externally. Owned scratch is disposable, but evidence must survive cleanup until its approved retention expires.

Report regeneration must validate its original inputs and artifact hashes. A saved report can remain readable after edits even when regeneration is no longer valid. Normalized reports can be deterministic for identical validated inputs; raw logs need not be byte-reproducible.

Clean only the run's owned resources. Do not globally prune caches, temporary directories, or other runs after interruption.

## 6. Compare against a trusted baseline

Start with report-only collection. To enable a regression ratchet, retain a trusted base revision's report **before** candidate changes, using the same approved measurement policy and compatible environment. Do not compare a candidate against itself or silently replace an incompatible baseline.

After artifact storage is authorized, use a fresh approved `ARTIFACT_DIR` for the
comparison run. Replace the baseline example with the resolved absolute path of
the trusted report in its approved retained run; confirm read access separately:

```sh
BASELINE="/absolute/approved-baseline-run/crap/report.json"
make quality-crap ARTIFACT_DIR="$ARTIFACT_DIR" \
  OUTPUT="$ARTIFACT_DIR/crap" BASELINE="$BASELINE"
```

A current function is a regression under the default ratchet when:

```text
current CRAP > 30
AND
(function ID is absent from baseline OR current CRAP > baseline CRAP)
```

| Baseline → current | Regression? |
| --- | --- |
| New function → 42 | Yes |
| 20 → 31 | Yes |
| 50 → 51 | Yes |
| 50 → 50 or 49 | No: stable/improved existing debt |
| 20 → 29 | No: worsening below the threshold is not gated |
| New function → 30 | No |

Compatibility includes the schema, scoring policy, source/test selection rules, coverage basis/fallback, complexity convention, adapter versions, relevant runtime/compiler/platform, instrumentation settings, and skip policy. Source and test changes are expected; identical repository fingerprints across revisions are not required. Record dependency lockfiles and assess changes for measurement impact; if a profile requires exact lockfile equality, changing it requires an approved compatibility decision or rebaseline.

Use function identities that survive ordinary line insertions, such as relative path plus lexical name/kind and disambiguator. Renames, moves, and callback reordering can change identity. A removed or renamed hotspot is not automatically an improvement; inspect its replacement responsibility and extracted functions.

The common collector should distinguish three outcomes:

- **Valid report, no regression** — or report-only mode without a baseline.
- **Invalid/incomplete measurement** — prerequisites, test execution, mapping, provenance, or compatibility failed.
- **Valid report, regression found** — retain authorized evidence even though the gate fails.

A suggested direct-CLI convention for diagnostic/ratchet mode is `0`, `1`, and `2` respectively. The process's strict gate must additionally fail for any eligible score `>=30`, even when there is no ratchet regression. Native tools may differ; the adapter must normalize them. Make may collapse different recipe failures into its own failure status, so CI needing the distinction should invoke the collector directly or inspect its structured status without discarding the command's failure.

**Success without a baseline does not mean zero hotspots.** It means a valid report was produced. Stable existing debt is permitted by this ratchet; debt reduction needs deliberate follow-up work.

## 7. Turn a hotspot into safer code

1. **Select a consequential, bounded responsibility.** Combine the metric with expected changes and failure impact. A lower-scoring authorization or recovery path may matter more than a higher-scoring peripheral utility.
2. **Establish intended behavior.** Read the specification, stories, and acceptance criteria. Resolve contradictions with the user; existing code is not the specification.
3. **Protect the planned change.** Add meaningful requirements-based tests before substantial restructuring where protection is weak. Assert outputs, permitted/rejected transitions, side-effect ordering, and effects that must not occur.
4. **Refactor in small steps.** Separate cohesive responsibilities, such as policy from side effects. Introduce the smallest safe seam where testing is blocked. Do not demand 100% coverage before every refactor.
5. **Rerun focused tests, then collect fresh scores.** Run the broader project checks and runtime verification required by the affected behavior. CRAP is not acceptance evidence.
6. **Inspect the whole affected area.** Confirm improved clarity without new coupling, arbitrary indirection, or hidden complexity in extracted functions. Use `code-simplifier` when required by the Coding process.

| Situation | Preferred response |
| --- | --- |
| High complexity, weak relevant tests | Add behavioral protection before substantial restructuring. |
| High complexity, strong relevant tests | Check assertion quality, then make small structural improvements. |
| Moderate complexity, low coverage | Test important missing behavior; a structural rewrite may be unnecessary. |
| Complexity above 30, full coverage | Reduce complexity if the area warrants work; execution coverage alone cannot remove the hotspot. |
| Coverage limited by skips or process boundaries | Investigate measurement scope before adding redundant tests. |
| Rarely changed, low-consequence hotspot | Consider deferring behind more consequential work. |

Characterization tests may explain unfamiliar behavior, but must not canonize known requirements or security defects. Separate authorized behavior correction from behavior-preserving refactoring where practical. Targeted mutation testing can help assess whether incorrect critical logic actually causes test failures.

Do not remove defensive checks, add assertion-free tests, broaden exclusions, mechanically split functions, or change the baseline to improve the metric. **Success is safer change with requirements preserved—not merely a score below 30.**

## 8. Troubleshooting

| Symptom | Action |
| --- | --- |
| Missing tools or version mismatch | Restore the authorized pinned environment; do not install automatically or invent scores. |
| Failed, empty, timed-out, or interrupted tests | Inspect execution evidence; fix the cause and collect afresh. |
| Missing or ambiguous coverage mapping | Investigate parser/provider/source-map compatibility. Do not substitute file coverage. |
| Apparently uncovered subprocess or generated code | Check the profile's measurement boundaries and instrumentation. |
| Inputs changed during collection | Stop concurrent edits and recollect from a stable revision. |
| Artifact hash mismatch | Reject the collection; do not edit hashes or combine unrelated runs. |
| Incompatible baseline | Investigate policy/toolchain drift or obtain approval for intentional rebaselining. |
| `30.00` is a hotspot | Inspect the unrounded score. |
| A hotspot disappears after rename/extraction | Review identity changes and the entire responsibility manually. |
| Scores shift without intended behavior changes | Check skips, provider changes, runtime/build settings, nondeterminism, and coverage basis. |

# Part II — Implementing language-specific tooling

## 9. Separate the shared engine from language adapters

Do not port the historical TypeScript scripts by replacing file extensions. Build a small shared scoring/reporting contract and implement the language-dependent measurements behind it. Existing trustworthy tools may supply parts of this pipeline; a new analyzer is not automatically required.

The shared engine should handle:

- Formula, full-precision thresholding, and the approved regression policy.
- Common report schema, deterministic ordering, rollups, and comparison results.
- Provenance validation, output ownership, failure states, and artifact lifecycle.

Each language adapter should handle:

- Production-function discovery and stable identities.
- The language's declared cyclomatic-complexity convention.
- Fixed test execution and coverage collection.
- Mapping provider data to original source functions.
- Runtime/compiler/build configuration, synthetic functions, and unsupported constructs.
- Normalization into the common schema, with explicit coverage semantics.

For polyglot products, keep separate profiles and baselines per language/component. A top-level Make target may orchestrate them and summarize status; it must not merge incompatible coverage fractions or rank languages as if their scores were calibrated identically.

## 10. Define the profile and normalized data first

Before selecting tools or writing adapters, agree on:

1. **Scope:** production paths, eligible function kinds, generated/vendor exclusions, and handling of erased or abstract declarations.
2. **Complexity:** cyclomatic counting rules for decisions, short-circuit operators, pattern matching, exception handling, nested functions, and language-specific constructs. Cognitive complexity and weighted assignment/call metrics are not drop-in substitutes.
3. **Coverage:** branch outcomes, branch arcs, source lines, statement blocks, or another defensible per-function basis. Name adaptations explicitly, for example `go-statement-blocks-v1`, rather than labeling them branch coverage.
4. **Fallbacks and gaps:** when an invocation fallback is valid, how unexecuted files are represented, and which missing data makes a run incomplete.
5. **Execution:** selected tests, skip policy, subprocess coverage, platform/features/build tags, concurrency, timeouts, and environment isolation.
6. **Compatibility:** which exact tool/runtime/compiler/configuration changes invalidate comparisons, plus the process for approved rebaselining.
7. **Operation:** output permission, destinations, retention, thresholds, and CI failure handling.

At minimum, normalize these fields:

| Level | Required information |
| --- | --- |
| Collection | Schema version, success/incomplete status, revision/dirty state, input hashes, profile/policy, exact analysis tool versions, applicable runtime/build/platform, test/skip summary, raw-artifact hashes. |
| Function | Language/component, stable ID, relative source path, kind/name, source span, complexity, coverage basis, coverage fraction, measured counts when available, full-precision CRAP, and mapping validity. |
| Comparison | Baseline identity, compatibility result, matched/new/removed functions, new/worsened hotspots, and overall outcome. |

Require finite values, `C >= 1`, `0 <= v <= 1`, valid counters and denominators, unique IDs, and trustworthy source mappings. Do not use a shared schema to conceal different measurement meanings.

## 11. Candidate building blocks by language

These are implementation options, not finished CRAP adapters or guarantees that a CLI report already provides the required function-level joins. Pin versions, inspect machine-readable output, and prove the mapping with fixtures before adoption.

### TypeScript

- **Function inventory and complexity:** use the [TypeScript compiler API](https://github.com/microsoft/TypeScript/wiki/Using-the-Compiler-API) or another pinned AST analyzer with explicit counting rules.
- **Coverage:** [Vitest](https://vitest.dev/guide/coverage) with a fixed provider. Istanbul supplies function locations/counters and branch outcomes suitable for a source-level adapter. V8 is another supported provider, but changing provider requires validated equivalence or a new profile/baseline.
- **Mapping work:** handle original TS/TSX source spans, nested callbacks, constructors, methods, accessors, source maps, and type-only declarations. Include unimported source files explicitly; Vitest's default imported-file coverage is not sufficient for a full source inventory.
- **Historical reference:** the recorded TypeScript profile uses an AST convention plus Istanbul branch outcomes, with a visible invocation fallback. That is one specific adaptation, not a language-wide CRAP standard.

### Python

- **Function inventory and complexity:** [Radon](https://radon.readthedocs.io/en/latest/) provides cyclomatic-complexity analysis. Select function/method records rather than class aggregate scores; define nested functions and asynchronous constructs explicitly.
- **Coverage:** [coverage.py](https://coverage.readthedocs.io/) with branch measurement, typically driven by the project's existing test runner. Configure source discovery so unexecuted modules are included where supported.
- **Mapping work:** use reported executed/missing branch destinations and branch totals, or reconstruct them using validated provider APIs. Raw executed arcs include ordinary line transitions and entry/exit markers: counting all arcs is not branch coverage, and executed arcs alone do not establish the denominator. Use branch-only counts, not a combined statement-and-branch percentage. Verify function-region support in the pinned report format and handle decorators, closures, same-line expressions, and subprocess coverage deliberately.
- **Profile decision:** use branch coverage only when the adapter can assign its opportunities to the correct lexical function accurately. Otherwise name a per-function line-based adaptation and keep it separate from branch-based baselines.

### Rust

- **Function inventory and complexity:** evaluate [rust-code-analysis](https://github.com/mozilla/rust-code-analysis) or a parser-backed implementation that exposes cyclomatic metrics for the Rust syntax used by the project.
- **Coverage:** [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov) supplies LLVM-based coverage and [machine-readable export](https://llvm.org/docs/CommandGuide/llvm-cov.html#export-command). Its current documented branch coverage is unstable and requires nightly Rust. Preserve function/region detail rather than summary-only output; ordinary region/line output is not branch coverage.
- **Mapping work:** reconcile source-analyzer function spaces with LLVM identities, accounting for macros, closures, generated entities, generic instantiations, inlining, and compiler source ranges. Do not blindly merge counts from multiple instantiations, treat nested-space aggregate complexity as a function's own complexity, or assume every region is a function.
- **Profile decision:** pin the compiler, LLVM tooling, features, targets, and optimization/instrumentation settings. If only defensible region or line coverage is available, use a separately declared adaptation rather than inventing branch outcomes.

### Go / Golang

- **Function inventory and complexity:** use the standard `go/parser` and `go/ast` packages or [gocyclo](https://github.com/fzipp/gocyclo), with explicit treatment of function literals. The inspected gocyclo traversal includes nested function-literal decisions in enclosing results; do not assume independent nested-function scoring without adapting and testing that behavior. Do not substitute cognitive-complexity results.
- **Coverage:** [`go test` coverage](https://go.dev/blog/cover) measures statement execution in instrumented blocks, not general branch-outcome coverage. `go tool cover -func` is useful for inspection, but its rounded displayed percentages should not be authoritative scoring inputs.
- **Mapping work:** join raw covered source blocks to function spans and weight by statement counts, not one vote per block. Handle closures and multiple constructs on one line, and account for package selection, build tags, platforms, coverage mode, and `-coverpkg` scope.
- **Profile decision:** use a clearly named per-function statement-coverage adaptation unless additional instrumentation genuinely measures branches. Record the weighting/denominator; do not present it as directly comparable to TypeScript or Python branch profiles.

### Ruby

- **Function inventory and complexity:** [RuboCop's cyclomatic-complexity rules](https://docs.rubocop.org/rubocop/cops_metrics.html#metricscyclomaticcomplexity) and its parser infrastructure can inform an adapter. Standard violation output is not a complete per-function inventory; dynamic definitions and blocks require an explicit scope.
- **Coverage:** [SimpleCov](https://github.com/simplecov-ruby/simplecov) wraps Ruby coverage facilities, including branch coverage where supported. Enable coverage before loading application code and include unexecuted files appropriately. Its documented line/branch criteria do not automatically provide method-hit counters.
- **Mapping work:** inspect raw branch data and method/source spans to assign counters to lexical functions, distinguishing blocks, singleton methods, metaprogramming, and subprocesses. A whole-file SimpleCov percentage is not a per-method score.
- **Profile decision:** pin Ruby, parser, coverage configuration, and adapter behavior. A method-invocation fallback may require a separate integration with [CRuby's Coverage API](https://ruby-doc.org/3.3.0/exts/coverage/Coverage.html); validate its compatibility with the chosen collector. Do not infer invocation from a file total or claim SimpleCov supplies it automatically.

## 12. Implement and validate incrementally

1. **Build one vertical slice.** Discover a small fixture function, measure complexity and coverage, map the records, score it, and produce the normalized result.
2. **Test the formula and boundaries.** Include zero/full coverage, `C=6` with zero coverage producing 42, exactly 30 versus just above 30, and rejection of invalid numeric input.
3. **Test syntax and ownership.** Include nested functions/closures, same-line constructs, methods, constructors, branchless functions, unexecuted files, and the language-specific constructs the adapter claims to support.
4. **Test the real provider.** Run a minimal fixture through the actual pinned parser/compiler and coverage provider. Handwritten JSON tests alone cannot detect provider-format or source-mapping drift.
5. **Test failures and provenance.** Cover failed/empty tests, missing/ambiguous mappings, unsupported syntax, source edits during collection, tampered artifacts, unsafe output paths, interrupted runs, and incompatible baselines.
6. **Test regression matching.** Cover new hotspots, stable/improved debt, threshold crossing, deleted/renamed functions, ordering stability, and nested-function identity changes.
7. **Wire Make and CI.** Expose the common commands, normalize native exits, preserve failures, and retain only authorized evidence. Keep dependency installation separate.
8. **Adopt report-only first.** Review surprising results and costs on representative code. Approve a trusted baseline and ratchet only after measurement is useful and stable.

A language adapter is ready when its measurement semantics are documented, supported functions have validated joins, incomplete collections cannot pass, normalized output is deterministic, and CI distinguishes measurement failure from a genuine regression. An unsupported construct is an explicit gap—not permission to silently improve the score by excluding it.

## 13. References and implementation map

### Background read for this runbook

- [Original CRAP proposal — Alberto Savoia](https://www.artima.com/weblogs/viewpost.jsp?thread=210575): motivation, formula, basis-path coverage, and the warning against using a metric as a universal code-quality or developer-performance score.
- [NDepend: The CRAP Metric](https://blog.ndepend.com/crap-metric-thing-tells-risk-code/): practical risk interpretation and threshold discussion; note its arithmetic typo and tool-specific length filter described above.
- [Fowler: Test Coverage](https://martinfowler.com/bliki/TestCoverage.html): coverage helps identify untested code but does not prove test quality.
- [Vitest coverage](https://vitest.dev/guide/coverage): provider selection, source inclusion, instrumentation, and mapping considerations for the TypeScript implementation.

The language-specific tool links in section 11 are starting points for adapter development, not evidence that interchangeable cross-language measurements already exist.

### Original TypeScript implementation — historical reference

The source runbook was written for a TypeScript project; see the [source attribution](../README.md#license). The following paths are **relative to that project**, not this process folder. They were named by the original runbook; those implementation files were not available locally for inspection during this rewrite.

| Historical project path | Responsibility recorded in the original runbook |
| --- | --- |
| `docs/testing/crap-scoring.md` | Project-specific operating guidance and policy. |
| `Makefile`, `package.json` | User-facing commands and pinned dependencies. |
| `test/codequality/run.mjs` | Collection, test environment, and manifest lifecycle. |
| `test/codequality/vitest.config.mjs` | Fixed source-test coverage profile. |
| `test/codequality/metrics.mjs` | Complexity, AST/coverage joining, scoring, rollups, and comparison. |
| `test/codequality/report.mjs` | Artifact validation and report generation. |
| `test/codequality/io.mjs` | Fingerprints, output ownership, and version checks. |
| `test/codequality/metrics.node-test.mjs` | Scoring-tool regression tests. |

The original runbook records `source-tests-v1` and `typescript-classic-v1`, Istanbul branch outcomes with an invocation fallback, and exact project-specific Node/Vitest/TypeScript pins. Do not apply those pins, test globs, environment variables, exclusions, or verification commands to another project without deliberate adaptation.

For a new project, record the equivalent implementation map and profile in its existing approved tooling documentation or `AGENTS.md`. Reuse the shared operating contract, not historical project assumptions.
