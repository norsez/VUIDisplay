# AGENTS.md — Processing Sketch Workspace

> **Copy this file as `<workspace>/AGENTS.md` when initializing a `processing-java-sketch` stack.**
> Fill `norsez`, `interactions/product_owner.md`, `/Users/norsez/code/project template` at init.
>
> This is a **Processing Java Mode** workspace. `.pde` files, run by the Processing IDE. The sketch is
> the product. There is no build tool, no test suite, and no deploy target — those are waived here and
> declared below, not left to be discovered.
>
> Shared instruction files live in the template repo and are **referenced by stubs, not copied.**
> See the stub files next to this one.

---

## Purpose

norsez writes Processing sketches. This workspace holds one: its `.pde` tabs, its `data/`
folder, and its history. I work as the engineer on that sketch — read the tabs, change the code, open
the IDE, judge what the change did.

The sketch is not a library and not a service. It runs once, on this machine, in a window. What "works"
means is that it opens and looks right. Only norsez can see the window; I reason about the
code and report what I changed, never that it looks correct.

---

## Change requests

**No big code change without a change request.** The gate fires on:

- **A behaviour change.** Any edit that changes what the sketch draws, plays, or records. A flag default,
  a frame rate, a display added to or removed from the list, a smoothing factor, a threshold.
- **A new dependency.** A new library import, or a new asset in `data/`.
- **A deletion.** Removing a `.pde` tab, a `data/` file, or a directory.
- **Adding a build file.** `pom.xml`, `build.xml`, or any dependency manifest. This is the signal the
  stack has changed — see §Not in this stack.

Refactors that leave behaviour identical need no change request: renaming a local variable, extracting a
method, reformatting, adding a comment.

Each request is a file in `change_requests/` seeded from `change_requests/_TEMPLATE.md`, named
`<yyyyMMdd>_<slug>.md`, moving `draft → review → accepted → done`. **A behaviour change goes into
`change_requests/`, not straight into a `.pde` tab.**

AI uses CR to check if the implementation matches the user's big picture goal to call it complete.

## Naming

- **The sketch folder name must equal the main tab name.** `VUIDisplay/` needs `VUIDisplay.pde`. The IDE
  opens nothing otherwise, which reads as a broken app. Never rename one without the other.
- Change requests: `<yyyyMMdd>_<slug>.md`. Lowercase. Underscores. No spaces.
- Never rename a tab, a `data/` file, or a class the owner wrote. F-3.

---

## Folders

- `.pde` files at the sketch root. The main tab is named after the folder. Other tabs may hold any class
  name — `DisplayFFT.pde` holding `DisplayFFTAlphaBall` is correct, not a bug.
- `data/` — every asset `loadImage`, `loadFont`, `SoundFile`, and `dataPath` read. A sketch folder without
  it cannot run. Committed, because the sketch cannot run without it on any other machine.
- `change_requests/` — the record of every behaviour change, dependency, and deletion.
- `.agents/skills/` — canonical skills (Tier 0). `.opencode/` — registry and pointer stubs.
- `export/` — exported applications. Gitignored. Machine-specific build output.
