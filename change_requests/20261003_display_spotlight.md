---
status: done
author: norsez
date: 2026-10-03
scope: Rotate a full-opacity spotlight across the 9 numbered displays every 3 seconds, dimming the rest to 40%
principles_checked: F-1, F-2, F-3, F-5
---

# Display spotlight: one at 100%, the rest at 40%, rotating

## Why
- When all 9 numbered displays are up, they draw at full opacity and cover each other. The last one
  drawn simply wins where they overlap, so there is no visual hierarchy at all.
- The mechanism for a spotlight already existed and was switched off:
  `LayoutWithFixedDisplaySet`'s constructor set `useFullAlphaLayerMode = false`, which made the tint
  branch at `LayoutAllInOne.pde:28` always take `noTint()`.
- The timer was not a timer. `nextSwitch = frameCount * random(0.5, 2.1)` multiplied absolute frame
  count by a random factor, so the gap grew the longer the sketch ran.
- `calcNextSwitch()` picked the spotlight by shuffling and taking the first entry, which walked the
  list until the first display happened to roll unhidden. With `maxDisplays = 1` over 9 displays
  that made `DisplayLaserPaint` the winner roughly half the time and `DisplayBarWaveForm` a quarter.
  Not a rotation.
- Rotation only ran when `isAuto` was true, which is false until `Z` is pressed.

## What / How
- `LayoutAllInOne.pde`, rewritten around the spotlight:
  - `dimAlpha = 102` (40% of 255). The focused display draws at 255, everything else at 102.
  - `spotlightMsec = 3000`, `handFadeMsec = 500`.
  - `advanceSpotlight()` steps `fullAlphaLayer = (fullAlphaLayer + 1) % displays.size()` and skips
    hidden displays, wrapping back to the previous index if every display is hidden.
  - `alphaFor(i, handT)` crossfades the handover: the incoming display ramps `dimAlpha` to 255 while
    the outgoing ramps 255 down to `dimAlpha`, so a switch reads as a cue rather than a glitch.
  - `resetSpotlight()` settles the focus on display 1 with no fade.
  - The `isAuto` gate is gone from `draw()`; rotation runs from the first frame.
  - The clock is `millis()` rather than a frame count, so 3 seconds stays 3 seconds when the frame
    rate drops.
  - Removed `maxDisplays`, `switchFrame`, `nextSwitch` and `calcNextSwitch()`. The random
    show-or-hide pass they implemented is gone: all 9 displays stay visible for the whole run and
    brightness alone carries the hierarchy.
- `LayoutWithFixedDisplaySet.pde`:
  - `super.maxDisplays = 1` removed; `super.useFullAlphaLayerMode = true` set explicitly rather than
    left to the default.
  - `bang()` calls `super.resetSpotlight()` instead of setting `fullAlphaLayer = 0` directly.
- `AbstractLayout.isAuto` and `toggleAuto()` are unchanged. `isAuto` now means "turn-taking is
  running", so `Z` pauses and resumes the rotation and the key is no longer wasted.

## Does this change what appears on screen?
- [x] Yes — dim values, which display is focused, and when it changes.

## Dependencies
- [x] No new library, no new asset in `data/`

## Out of Scope
- The `1`-`9` keys still hide a display on demand; nothing about them changed.
- `fixedDisplays` still composite at `tint(255, 200)` on top. Untouched.
- The per-frame `createGraphics(bound)` at `LayoutAllInOne.pde`. Still allocated every frame, same
  shape as the old bloom cost and now the largest remaining allocation in the frame. Deliberately a
  separate change request rather than a rider here.
- The `layout = new LayoutAllInOne(bound, displays);` at `LayoutWithFixedDisplaySet.pde:29`, which
  resolves to no field this class or any ancestor declares. Flagged in review, left alone, and not
  touched by this change.
- A brightness dial. The 100/40 split is fixed in code, not on a wheel control.

## Acceptance Criteria
- [ ] Sketch opens in the Processing IDE and runs.
- [ ] Exactly one of the 9 numbered displays is at full opacity; the other 8 are clearly dimmer.
- [ ] Focus advances 1, 2, 3 ... round to 1, every 3 seconds, with a visible but not slow fade.
- [ ] Pressing `Z` freezes the focus on the current display; pressing again resumes.
- [ ] Pressing `X` returns focus to display 1.
- [ ] Hiding the focused display with its number key does not stall the rotation.

## Open risk — needs the owner's eyes
- `tint()` reliably dims what a display draws as an `image()`. Displays that draw into their own
  buffer and blit it (`drawOn()` in `AbstractDisplay.pde:41`) are covered. A display that draws raw
  lines and shapes straight into the layout buffer will not dim, and will read as focused when it is
  not. `/check-deps` cannot see this; only running the sketch can.

## Note
- The 40% dim value was chosen by the owner explicitly, over a suggested 70%. `dimAlpha` in
  `LayoutAllInOne.pde` is the single place to change it.

## Principle Check
- F-1: no claim that it runs or looks right. The `tint()` coverage question is recorded as an open
  risk rather than asserted either way.
- F-2: "display", "spotlight", "sketch", `data/` used as the owner's terms.
- F-3: no tab, `data/` file, folder, or display class renamed. `LayoutAllInOne`,
  `LayoutWithFixedDisplaySet` and `toggleAuto()` all keep their names.
- F-5: recorded as a change request rather than changed silently. No conflict.