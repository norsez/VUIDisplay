---
status: done
author: norsez
date: 2026-10-03
scope: Turn the bloom pass on by default and widen its radius so it is actually visible
principles_checked: F-1, F-2, F-5
---

# Bloom on by default

## Why
- The bloom pass existed in `BloomPProcess.pde` but never ran: `APPLY_BLOOM = false` and nothing
  anywhere in the sketch flipped it — no key, no control panel toggle.
- Even once on, the radius was too small to read at 800x640.

## What / How
- `VUIDisplay.pde` — `APPLY_BLOOM` default `false` → `true`.
- `VUIDisplay.pde` — add a `L` key branch in `keyPressed()` that flips `APPLY_BLOOM` at runtime, so
  the effect can be compared on and off without a restart.
- `BloomPProcess.pde` — `BloomRadius` `4` → `12`.
- `BloomThreshold` stays at `100`.

## Does this change what appears on screen?
- [x] Yes — a flag default and a blur radius. The canvas now has an additive bloom pass over it.

## Dependencies
- [x] No new library, no new asset in `data/`

## Out of Scope
- `BloomThreshold`. Not touched.
- How `ApplyBloom()` works. Untouched.
- The `-100..100` vs `0..128` mismatch on `controlA` / `controlB` in `DisplayFFT.pde` and
  `DisplayBouncingLaser.pde`. Known, deliberately left alone by the owner this session.
- The redundant `SetUpTarget()` in the `BloomPProcess` constructor, which runs before `size()` and so
  builds a 100x100 target that `ApplyBloom()` immediately replaces. Harmless, left alone.

## Acceptance Criteria
- [ ] Sketch opens in the Processing IDE and runs.
- [ ] A visible glow around the brighter parts of the displays.
- [ ] `L` toggles the effect off and back on with no restart.
- [ ] Radius 12 judged by eye against the running sketch; adjust the single number if it is too much
      or too little.

## Principle Check
- F-1: no claim that it runs or how it looks. Only the code change is stated. The radius is offered as
  a starting value for the owner to judge in the IDE.
- F-2: "tab", "sketch", `data/` used as the owner's terms.
- F-3: no tab, `data/` file, or folder renamed.
- F-5: recorded as a change request rather than made silently. No conflict.