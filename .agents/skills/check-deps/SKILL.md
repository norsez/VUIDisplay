---
name: check-deps
description: Resolve every import in every .pde tab against core.jar plus the sketchbook libraries and report the ones that cannot be found. Use when the user types /check-deps, after a fresh clone, after adding a library, or when a compile error names a package rather than a library.
---

# /check-deps

Parses every `import` in every `.pde` tab and resolves each against Processing core plus the sketchbook
libraries. Reports what cannot be found.

## What this proves, and what it does not

| Proves | Does not prove |
|---|---|
| Every library this sketch imports is installed on this machine | That the sketch compiles |
| Which jar a given import was resolved from | That the code type-checks |
| Nothing else | Anything about how it looks when run |

**Never report this skill passing as "the sketch compiles."** It is narrower than that, and
`AGENTS.md` §The Loop says so. A type error reaches a human at Run time.

## Failure behaviour — mandatory

**Do not restate the failure protocol here.** It is owned by the active collaboration style named in
`AGENTS.md`, and it differs by style. Read that file and follow it.

Stack-independent rules that hold under every style: report each unresolved import verbatim as it
appears in the source, name the library directory that was searched, and never guess a version.

## Command

```bash
scripts/check_deps.py            # default: the sketch in the current directory
scripts/check_deps.py --sketch /path/to/SketchDir
scripts/check_deps.py --json     # machine-readable
```

Exit code `0` when every import resolves, `1` when any does not.

## How resolution works

1. **Core imports** — `processing.*`, `java.*`, `javax.*`, and anything else inside `core.jar`. Always
   resolve.
2. **Library jars** — every `~/Documents/Processing/libraries/*/library/*.jar`. Match on the top-level
   package each jar declares.
3. **Embedded packages** — some classes ship *inside* another library's jar rather than as a library of
   their own. `com.hamoid.*` is the case in this sketch: it lives in `VideoExport.jar`. A jar that is
   indexed by its internal packages resolves these correctly, so `com.hamoid` does not read as missing
   when VideoExport is installed.

Processing injects a set of default imports into every sketch. Those are resolved by rule and never
reported. Only explicit `import` lines are checked.

## Gotchas

- **`com.hamoid.*` is not an installable library.** It ships inside `VideoExport.jar`. Removing
  VideoExport removes it, and the compile error then names a package that does not exist on its own.
- **The sketchbook path is per-user.** Not `~/Documents/Processing` on every machine. The script reads
  the real one and prints it, so a wrong guess is visible.
- **A fresh clone resolves nothing.** Libraries are not vendored in the repo. A first `/check-deps` on a
  clean machine reports every non-core import missing, and that is correct, not a bug.
- **An asset is not an import.** `loadFont`, `loadImage`, `SoundFile` read from `data/`. This skill does
  not check `data/`. A missing font fails at Run time with a null, not a compile error.
- **Matching on the import path is not proof the symbol exists.** `import controlP5.*` proves
  `controlP5.jar` is on disk. It does not prove the class the code uses is in it.
- **Do not install anything.** Report what is missing and let the owner install through the
  Contributions Manager. A library installed into the sketchbook by script has no `library.properties`
  and the IDE will not see it.