---
status: draft
author: norsez
date: 2026-10-04
scope: Breathe brightness and contrast with a slow sine LFO plus a little audio noise, so the frame stays at its baseline look instead of being pushed past it
principles_checked: F-1, F-2, F-3, F-5
---

# Modulated brightness and contrast

## Why
- The owner judged `frame_composite_0_baseline` the best-looking output of the
  three-method POC in `poc/poc_filter/`. That is the frame with no bloom and no
  filter applied to it.
- The POC also showed that pushing this content with a static filter damages it. The
  frame is 80-95% black, so a contrast pivot at mid grey expands a range almost
  nothing occupies. At `contrast 1.4` lit pixels fell from 57.80% to 11.58% while
  10810 pixels clipped at the top. At `brightness +40` every pixel became lit
  (100%) and the mean rose 3.7x.
- So a static brightness/contrast pass is the wrong shape for this sketch. What is
  wanted is the baseline look kept as the resting state, with the frame very
  slightly alive — a slow sine, plus a little audio-driven noise on top.

## What / How
- New tab `ModulatedGrade.pde`, holding one class `ModulatedGrade`. No tab renamed,
  no existing class renamed.
- `VUIDisplay.pde` — one new field, `ModulatedGrade grade = new ModulatedGrade();`
  beside `BloomPProcess bloom`.
- `VUIDisplay.pde` `draw()` — a new call `grade.Apply(ampsum)` placed after
  `bloom.ApplyBloom()` and before `videoExport.saveFrame()`. After bloom so the glow
  is graded too; before the export so recorded video matches what is shown.
- `VUIDisplay.pde` `setup()` — one line added to `printKeyMap()`.
- The pass itself is a `loadPixels()` / `updatePixels()` loop over the main canvas,
  the same idiom `BloomPProcess.ApplyBloom()` already uses. Renderer-independent,
  which is why this shape was chosen: the shader alternative forces `size()` onto
  P2D, and that shifts font AA and `image()` smoothing for the whole sketch, a far
  larger visual change than the grade itself.
- Formula, per channel, `pivot = 127.5`:
  `out = (in - pivot) * contrast + pivot + brightness`, clamped to 0..255.
- Modulation:
  - `sine` and `sine2` are two `LFO(LFO.SHAPE_SINE, ...)` instances at 8 and 13
    second periods, so contrast and brightness do not rise and fall in lockstep.
  - `noise = random(-1, 1) * 0.5 + (ampsum - 0.5)`
  - `contrast = 1.0 + 0.12 * (0.7 * sine + 0.3 * noise)`, so contrast rests at 1.0
    and swings roughly 0.88..1.12.
  - `brightness = 8.0 * sine2`, so brightness swings -8..+8.
  - Both clamped to the bands above as a guard.
- `ampsum` is the existing per-frame smoothed amplitude from `AudioInput.pde`, already
  updated by `tickAmp()` at `VUIDisplay.pde:111`. Not re-read, not re-smoothed.
- New key `M` toggles the whole grade on and off at runtime, matching how `L` toggles
  bloom, so the effect can be compared without a restart.
- When the grade is off, or when contrast is exactly 1.0 and brightness exactly 0,
  the pixel loop is skipped entirely. Idle frames cost nothing.
- `APPLY_BLOOM` stays `true`. The owner confirmed bloom stays on; it is graded, not
  changed.

## Does this change what appears on screen?
- [ ] No — pure refactor, behaviour identical. This request is informational.
- [x] Yes — a flag default, a display added or removed, a smoothing factor, a
      threshold, a frame rate.

## Dependencies
- [x] No new library, no new asset in `data/`
- The fragment shader from the POC (`poc/poc_filter/data/poc_bc.frag`) is not used
  and no `.frag` is added to `data/`. This is the main reason the CPU pass was
  chosen.

## Out of Scope
- `BloomPProcess.pde`. Untouched. The POC noted that making bloom reusable as a post
  pass would mean changing it to take a source image rather than reading the main
  canvas. This request does not need that — the grade runs after bloom on the canvas,
  exactly where bloom already draws.
- `APPLY_BLOOM`, still `true`, and `BloomRadius`, still `12`.
- `BloomThreshold`, still `100`.
- Method C from the POC (composite `PGraphics`, then one blit). The POC measured it
  byte-identical to this CPU pass, so it buys nothing here.
- Method B (fragment shader). Unavailable to test on this machine, and it forces P2D
  on the main canvas.
- `smoothingFactorAmp` (`0.70`) and `smoothingFactorFFT` (`0.90`). The noise term
  reads `ampsum` as it already is; it does not re-tune the smoothing that produces it.
- `controlA`..`controlD`, the wheel, and the known `-100..100` vs `0..128` mismatch
  in `DisplayFFT.pde` and `DisplayBouncingLaser.pde`. Left alone, as in every previous
  request this session.
- Making depth, brightness range, or the LFO periods adjustable at runtime. Four
  constants at the top of `ModulatedGrade.pde` are the whole control surface for now.
- The `int[] displayKey` at `VUIDisplay.pde:124`, still unused. Deleting it is a free
  refactor whenever wanted.
- Cost. Nothing in the POC was timed, so the cost of the extra canvas-sized loop per
  frame is unknown and is not claimed here.

## Acceptance Criteria
- [ ] Sketch opens in the Processing IDE and runs.
- [ ] The resting frame matches the baseline look the owner picked — no visible
      crush toward black, no visible lift of the black floor.
- [ ] Over roughly 8 seconds the frame very slightly brightens and darkens, and the
      brightness and contrast cycles are not visibly in step with each other.
- [ ] `ampsum` drives the noise term, so the grade reacts audibly.
- [ ] `M` toggles the grade off and back on with no restart.
- [ ] `L` still toggles bloom, and the two toggles are independent.
- [ ] With the grade off, the frame is the same as it was before this change.

## Open risk — needs the owner's eyes
- The POC could only judge single frames. A static frame cannot show what a per-frame
  contrast change does to flicker or to audio-driven noise, and this change is
  entirely about motion. Depth `0.12` is a deliberately small starting value; if it
  reads as a wobble rather than a breath, it goes down, not up.

## Trade-off taken
- CPU loop over shader. Costs a per-frame pass over every canvas pixel and gives up
  the shader's easy path to curves and gamma later. In exchange the main canvas stays
  on its current renderer, so nothing else in the sketch shifts. Chosen because the
  POC showed the shader's real cost is the renderer change, not the filtering.

## Note
- The contrast swing dips below 1.0, roughly to 0.88. That direction reduces contrast
  rather than increasing it, so it lifts the blacks slightly instead of crushing
  them — the opposite of the `1.4` result the POC flagged as damage. If it reads as
  a grey haze rather than a breath, raise the floor to 1.0 and let the sine only ever
  add contrast.

## Principle Check
- F-1: no claim that the sketch runs, holds 60, or looks a particular way. Every
  number quoted from the POC is counted from pixels in `poc/poc_filter/out/`, not
  measured on a running sketch. The POC's own README records that it could not
  exercise the shader path.
- F-2: "tab", "sketch", "canvas", `data/` used as the owner's terms. "Grade" and
  "modulated contrast" are the owner's words for this request.
- F-3: no tab, `data/` file, display class, or sketch folder renamed. `BloomPProcess`,
  `LayoutAllInOne`, `toggleAuto()` and all others keep their names. One new tab added.
- F-5: recorded as a change request rather than changed silently, because it alters
  what appears on screen every frame. No conflict.