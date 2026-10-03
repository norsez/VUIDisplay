---
status: done
author: norsez
date: 2026-10-03
scope: Make the bloom pass cheap enough to be free — downsample the bloom buffer, allocate its scratch once, and interpolate the upscale
principles_checked: F-1, F-2, F-5
---

# Bloom: downsample and hoist the allocations

## Why
- The bloom pass allocated roughly 8.2 MB of garbage every frame and ran its blur over every
  canvas pixel, which is why it never looked worth turning on.
- `SetUpTarget()` was called from `ApplyBloom()`, so a full-size image was rebuilt each frame on
  top of three `int[]` arrays sized to the canvas.
- Its black-fill loop was dead work: it filled `bloomTarget.pixels` and never called
  `updatePixels()`, so the fill never reached the image.

## What / How
- `BloomPProcess.pde` only. `VUIDisplay.pde` is not touched.
- New `BloomScale = 4`. `bloomTarget` is now `width/4` x `height/4` (200x160) instead of canvas
  size.
- `BloomExtract()` now max-downsamples each `BloomScale` x `BloomScale` block of the canvas, then
  applies the brightness threshold on the downsampled pixel. Max is per channel, so a block is
  never darker than the brightest pixel inside it and 1-pixel highlights survive.
- `Blur()` now writes into `bufR`/`bufG`/`bufB`/`dv`/`vmin`/`vmax`, allocated once in
  `SetUpTarget()`. Per-frame allocation is zero.
- `SetUpTarget()` is no longer called from `ApplyBloom()`. `TargetIsStale()` re-sizes it if the
  canvas or the radius changes, so a window resize still works.
- The dead black-fill loop is gone. `SetUpTarget()` no longer calls `loadPixels()`.
- `TargetRadius()` returns `BloomRadius / BloomScale`, so `BloomRadius` stays measured in canvas
  pixels and keeps its approved value of 12.
- The composite is now `blendMode(ADD); image(bloomTarget, 0, 0, width, height); blendMode(BLEND);`
  instead of `blend()`. `blend()` does not interpolate when scaling, which was invisible while the
  source was 1:1 with the canvas and would have produced hard 4x4 blocks once it was smaller.
  `image()` interpolates, and that interpolation is what softens the glow.

## Does this change what appears on screen?
- [x] Yes — the glow gets wider and softer than the previous radius-12 box blur. Same additive
  model, no strength knob added.

## Dependencies
- [x] No new library, no new asset in `data/`

## Out of Scope
- `BloomThreshold`, still 100. `brightness()` is still used rather than a hand-rolled luma, so the
  threshold means exactly what it meant before.
- No `strength` knob on the composite. It remains a flat additive blend.
- The `A`/`B`/`C`/`D` wheel dials, including the `-100..100` vs `0..128` mismatch in
  `DisplayFFT.pde` and `DisplayBouncingLaser.pde`. Deliberately left alone by the owner.
- The redundant `SetUpTarget()` in the constructor, which still runs before `size()` at the 100x100
  default and is then replaced by `TargetIsStale()` on the first frame.
- A `PShader` implementation. Not this pass.

## Acceptance Criteria
- [ ] Sketch opens in the Processing IDE and runs.
- [ ] A glow around the brighter parts of the displays, wider and softer than before.
- [ ] `L` still toggles it, and `R` still zeroes the knobs.
- [ ] No visible grid of 4x4 blocks in the glow.
- [ ] If shimmer appears on fine detail, drop `BloomScale` to 2.

## Trade-off taken
- Downsampling can alias on fine detail. Bloom's own blur hides most of it. `BloomScale = 2` is the
  fallback if shimmer shows up; it is still much cheaper than the original.

## Principle Check
- F-1: no claim that it runs, nor how fast or how it looks. Every number here is counted from the
  source, not measured. `/check-deps` passing is not reported as compiling.
- F-2: "sketch", "canvas", `data/` used as the owner's terms.
- F-3: no tab, `data/` file, or folder renamed. Class and method names unchanged.
- F-5: recorded as a change request rather than changed silently. No conflict.