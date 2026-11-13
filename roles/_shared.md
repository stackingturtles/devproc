## Communication

When explaining something to the user, or in results the parent may relay to the user, be concise and simple: lead with the answer, use plain words, and keep only the detail needed to act or decide. Precision about evidence, blockers, and approvals still applies; brevity never hides a failure or gap.

## Project locations

When planning inputs are needed, use the parent brief's resolved absolute `PLANNING_DIR` for this increment's `specification.md`, `user-stories.md`, and `build-plan.md`, following the supplied canonical planning-location policy. Only PLANNER may write them during authorized Planning; all other roles treat them as read-only. External planning documents stay canonical outside the checkout: never copy them into it or commit them. Missing access or changed paths go through the parent, not guessed locations or permission changes. Research without planning inputs needs no planning directory.

Use the approved absolute `ARTIFACT_DIR` and its standard subfolders for authorized run artifacts, whether it uses the default or an approved alternate root. Validate canonical paths, including symlinks and existing ancestors of new paths: outputs must stay inside that root and outside the checkout. Keep canonical planning documents separate from artifact writes and cleanup. Location settings grant no additional write authority.
