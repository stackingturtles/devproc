# Notes verification map

This is an illustrative feature-map template, not a Notes application or a harness to install. Adapt its schema to the actual project at `skills/verify-<project>/features/`; do not copy the fictional commands as verified project instructions. The example is adapted from pstack under the parent skill's `LICENSE`.

For a generated project map, read the index before driving the app, then use the matching feature file as the recipe. The index and recipes are maintained source; execution evidence is external.

## Baseline preconditions

- Launch Notes at `http://127.0.0.1:4173` with a disposable data directory.
- Obtain the approved absolute `ARTIFACT_DIR` from the brief, outside the checkout after resolving symlinks; keep outputs inside that root. Both the default and an approved alternate run root use the same standard subfolders.
- Set `NOTES_DATA_DIR="$ARTIFACT_DIR/scratch/notes"` so concurrent runs do not share state. Create the required `verification/evidence/create-note/` and `verification/evidence/search/` subfolders under this run root before capture.
- Seed notes titled `Quarterly plan` and `Grocery list`.
- In this fictional example, `control-notes` and the `notes` CLI are already available on `PATH`. Real generated maps must use actual project tools; do not install these example names.
- Run `control-notes doctor` and require the expected URL, data directory, and build revision.
- Never drive an instance that was not started by this verification run.

## Driving conventions

- Start every recipe from the baseline state unless its preconditions say otherwise.
- Prefer ARIA roles and accessible names over CSS selectors or DOM position.
- Treat every command as literal. Keep quoted names and flags unchanged.
- Run browser actions through `control-notes browser`.
- Run terminal actions through `control-notes cli -- <command>`.
- Restore seeded data after a mutation. Do not remove proof artifacts during cleanup.

## Proof and skip reporting

- Capture the user action and the resulting state, not only the final screen.
- UI proof includes an ARIA snapshot and a screenshot with the app identity visible.
- CLI proof includes the command, stdout, stderr, and exit code.
- Mutation proof includes a read-only second view of the stored value.
- Record the feature ID and entry point used with every artifact.
- Report an unreachable path with the attempted command and the unmet precondition.
- Do not report a skipped entry point as verified through a different path.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with <harness>` starts with `Preconditions:` and uses labeled bullets that pair each user action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

Keep implementation details out of the map. Name only user paths, stable handles, required state, commands, and observable proof.

## Features

- [Create a note](./create-note.md) covers browser and CLI creation, cancellation, persistence, and cleanup.
- [Search notes](./search.md) covers toolbar, keyboard, and CLI search with matching, empty, and clear states.
