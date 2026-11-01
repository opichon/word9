[Home](../../index.md) › Architecture

# Architecture

Cross-cutting structure — the couplings and orderings that no single file makes obvious.

## System flows

- [App Startup](app-startup.md) - How a launch gets from main() to a playable grid: what runs off the UI thread, what does not, and what happens if the asset cannot load.
- [Built Versus Planned](built-versus-planned.md) - Which parts of the word9 spec exist on main and which are only planned, so that the specs are not read as a description of the code.
- [Entry Submission](entry-submission.md) - The path of a tap and an Enter through UI, controller and rules: the order of the checks, what each control clears, and what never changes the state.
- [Word Data Flow](word-data-flow.md) - How word lists get from SCOWL into the app, why the assets are committed, and the chain of checks that proves they still match Nine Tile.
