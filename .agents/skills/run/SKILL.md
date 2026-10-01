---
name: run
description: Open the sketch in the Processing IDE and report whether the sketch process actually started. Use when the user types /run, or asks to open, start, launch, or check whether the sketch is running.
---

# /run

Opens the sketch in the Processing IDE and reports whether the sketch process actually started.

## What this does, and what it does not

| Does | Does not |
|---|---|
| Open the sketch in the Processing IDE | Press Run |
| Report whether a sketch process is alive | Compile anything |
| Name the PID and the sketch path | Prove the sketch compiles |
| Detect a dead previous run | Say anything about how it looks |

**Opening the IDE is not running the sketch.** `open -a Processing <dir>` launches the editor. Nothing
compiles until a human presses Run. Never report a sketch as running on the strength of this skill.

## Failure behaviour — mandatory

**Do not restate the failure protocol here.** It is owned by the active collaboration style named in
`AGENTS.md`, and it differs by style. Read that file and follow it.

Stack-independent rules that hold under every style: quote any process output verbatim, and never
guess whether a failure is a compile error, a missing asset, or a crash — the three look identical
from outside the IDE.

## Commands

```bash
scripts/run.sh                          # open the sketch in this workspace
scripts/run.sh /path/to/SketchDir
scripts/run.sh --status                 # report only, open nothing
```

Exit code `0` when the IDE process is up, `1` when it is not.

## Gotchas

- **Match `processing.core.PApplet`, not the app path.** On macOS the IDE may run translocated from
  `/private/var/folders/.../AppTranslocation/...`. A `pgrep` written against `/Applications/Processing`
  misses it and reports a false negative.
- **Two processes, two answers.** The IDE and the sketch are separate. The IDE being alive says the
  editor is open. The `PApplet` child says the sketch is running. Report which one you found.
- **Autostart is unreliable.** Launching the IDE does not reliably start the sketch on macOS. This is
  not a failure — Run is a human button here.
- **The sketch folder name must equal the main tab name.** A mismatch means the IDE opens nothing and
  the app reads as broken. This skill reports the mismatch rather than launching into a blank editor.
- **Use `/check-deps` first on a fresh machine.** A missing library is a compile error the IDE reports
  cryptically. `/run` cannot diagnose it.