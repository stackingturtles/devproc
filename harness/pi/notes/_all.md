## Harness notes (Pi)

- **Supervisor channel:** `contact_supervisor`. Send `need_decision` for parent decisions and `interview_request` for structured interview rounds, then wait for the reply. Never invent user answers or approvals.
- **Skills:** `inheritSkills: true` exposes a catalog, not executed instructions. Read each required `SKILL.md` at the absolute path in the brief.
- **Tools:** the `tools` list is a strict allowlist; installed extensions do not override it, and a named extension tool requires a loaded provider.
