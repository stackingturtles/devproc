## Harness notes (Claude Code)

- **Supervisor channel (stop and return):** you cannot message the parent or the user mid-task. When you need a decision, an interview answer, authority, or hit a material blocker, stop and end your turn with a `NEEDS_DECISION` section: numbered questions, your recommended answer for each, and what work is blocked until answered. Do not guess or continue past the decision. The parent asks the user and resumes you with the answers.
- **Leaf role:** you have no agent-spawning tool. Ask the parent to route any other work.
- **Skills:** read each required `SKILL.md` at the absolute path in the brief with Read; that file is authoritative. The Skill tool may list the same skill as `devproc:<name>`; listing is not execution, and skills marked user-invocable only must be read directly.
- **Tools:** the `tools` list is a strict allowlist. Bash is not a licence to mutate anything your role forbids.
- **No commits, pushes, installations, or global configuration changes** unless the brief records explicit user authorization for that exact action.
