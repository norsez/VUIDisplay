---
status: draft
author: norsez
date: 2026-10-04
scope: Start the spotlight rotation from the first frame instead of leaving it switched off, and say both states out loud so the Z key is never ambiguous
principles_checked: F-1, F-2, F-3, F-5
---

# Spotlight: run from frame one, and report both Z states

## Why
- `Z` does not appear to do anything. Two things combine.
- `AbstractLayout.isAuto` is declared with no initializer, so it is `false`.
  `LayoutAllInOne.draw()` gates rotation on it:
  `if (super.isAuto && millis() - lastSwitchMsec >= spotlightMsec)`.
  The spotlight therefore does not rotate at all until `Z` is pressed, and the
  frame sits with display 1 at full opacity and the other eight dimmed, unchanged.
- `AbstractLayout.toggleAuto()` prints the empty string when it switches rotation
  **off**:
  `println(isAuto?"is auto layout":"");`
  So the second press of `Z` is completely silent. A press that prints nothing
  reads as a dead key.
- Neither is what the spotlight change request said would happen.
  `20261003_display_spotlight.md` line 34 states:
  "The `isAuto` gate is gone from `draw()`; rotation runs from the first frame."
  The gate is still there, at `LayoutAllInOne.pde:31`. That request describes
  behaviour the code does not have.

## What / How
- `AbstractLayout.pde` — `boolean isAuto;` gains an initializer, `true`.
  Rotation starts on the first frame, which is what the spotlight request intended.
- `AbstractLayout.pde` — `toggleAuto()` prints a word for both states instead of an
  empty string:
  `println(isAuto ? "spotlight rotation ON" : "spotlight rotation OFF");`
  Console only, nothing on screen.
- `LayoutAllInOne.pde` — not touched. The gate stays; it now starts open rather than
  closed, which is the smallest change that makes `Z` mean "pause / resume".

## Does this change what appears on screen?
- [ ] No — pure refactor, behaviour identical. This request is informational.
- [x] Yes — which display is focused, and when it changes.

## Dependencies
- [x] No new library, no new asset in `data/`

## Out of Scope
- `dimAlpha` (102), `spotlightMsec` (3000) and `handFadeMsec` (500). The rotation
  rate and the dim depth are not touched.
- `advanceSpotlight()` and `resetSpotlight()`. Unchanged.
- The `1`-`9` keys. Investigated here because the owner reported them not working,
  but **no code on that path was changed** — the key code already printed, `toggleHidden()`
  already flipped `hidden`, and every one of the nine displays already opens its `draw()`
  with `if (super.hidden) return;`. The owner has since reported the `1`-`9` keys working
  correctly, so nothing was broken and nothing needed fixing. See Open risk.
- `LayoutWithFixedDisplaySet.pde:29`, which assigns to a `layout` that no class in its
  chain declares. Flagged in the spotlight request and left alone. The owner's console
  shows the fixed-display overlay still running, so it is not the cause.
- `ModulatedGrade.pde` and the grade pass. Unrelated, and not the cause.

## Acceptance Criteria
- [ ] Sketch opens in the Processing IDE and runs.
- [ ] Without pressing anything, the focus starts moving: a `spotlight: display N`
      line appears in the console within about 3 seconds, and keeps appearing every
      3 seconds after that.
- [ ] Pressing `Z` prints `spotlight rotation OFF` and the focus stops moving.
- [ ] Pressing `Z` again prints `spotlight rotation ON` and it starts moving again.
- [ ] Neither press of `Z` is silent.

## Open risk — needs the owner's eyes
- Two lines in the spotlight request are not true of the code: the `isAuto` gate is
  still in `draw()`, and `Z` is described as pausing and resuming. This request makes
  the code match the description rather than the other way round. If the owner would
  rather have the spotlight stay still until asked for, the initializer goes back to
  `false` and only the printing changes.
- The `1`-`9` report is **closed**. The owner reports those keys work correctly now. No
  code on the key path was changed to achieve that, and this request does not claim to know
  why they read as broken earlier — only that the code path was correct at every step that
  can be read, and that the owner now sees them working.
- The `toggleHidden()` console line added while investigating that report
  (`AbstractDisplay.pde`) has been **reverted**. It was diagnostic scaffolding, never part
  of this request's scope, and `AbstractDisplay.pde` is back to its committed state.

## Principle Check
- F-1: no claim that the sketch runs or that the spotlight now visibly rotates. Every
  statement above is read from the source or from the owner's console output. The
  console evidence is the absence of any `spotlight: display N` line, which is
  consistent with rotation never having run but does not by itself prove the cause.
- F-2: "spotlight", "tab", "sketch", "canvas", "keys" used as the owner's terms.
- F-3: no tab, `data/` file, display class, or sketch folder renamed. `toggleAuto()`,
  `isAuto`, `advanceSpotlight()` and `resetSpotlight()` all keep their names.
- F-5: recorded as a change request rather than changed silently, because which
  display is focused, and when, changes on screen from the first frame.