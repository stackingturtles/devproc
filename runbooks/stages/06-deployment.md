# 06 — Deployment

## Use / Owner

Use only after review readiness and separate explicit user authorization. INFRA or the identified operator owns authorized delivery; identify the recovery owner. A green review does not grant production access, installation, publication, commits, pushes, migrations, or deployment.

## Read / Inputs

Read [Deployment](../../process.md#6-deployment) in full, the shared authority contract and artifact policy, target project instructions, applicable operational conventions, and current review evidence. Inputs must identify the exact reviewed revision, build configuration, verified artifact or image digest, approved target/action, smoke checks, and recovery plan. Read specialized operational references only as needed for the authorized target; do not impose server procedures on every product.

## Execute

1. Confirm user authority boundaries with the parent, responsible operator, target readiness, configuration, and least-privilege credentials without exposing secrets. Missing target or artifact identity is a blocker, not permission to choose one.
2. Match the release artifact to the reviewed candidate. Deliver that verified artifact; if a target-specific rebuild is necessary, establish its identity and applicable verification before delivery. Keep generated packages, logs, and evidence externally under the approved agreement.
3. For applicable migrations/destructive changes, obtain specific approval and agree backups, compatibility/rollout precautions, and recovery. Mark genuinely irrelevant concerns not applicable with a reason.
4. Execute only the authorized delivery/installation. Run agreed smoke checks against the installed/running product, including its critical user journey. Successful upload or installation alone is insufficient.
5. On failure, stop further rollout, notify the parent/user, and follow only the pre-approved recovery plan. Otherwise escalate to the recovery owner; do not improvise destructive commands.

## Handoff / Stop

Return delivered identity, environment, actual smoke outcomes, recovery status, and limitations in conversation. Extra deployment records require artifact permission. Pause after the authorized action; later increments return through parent-approved Planning rather than an autonomous new cycle.
