# POC: brightness + contrast as a last pass

Throwaway side project. Answers one question: **of the three ways to apply
brightness and contrast at the end of the sketch, which one, and do they look
different?**

No tab of the `VUIDisplay` sketch was modified. `BloomPProcess.pde` was read, not
touched.

---

## The three methods

| | Method | Where it runs | Needs |
|---|---|---|---|
| **A** | CPU pixel loop over `PImage.pixels` | any renderer | nothing |
| **B** | fragment shader | P2D/P3D only | `size()` on P2D, a `.frag` in `data/` |
| **C** | composite `PGraphics`, filter it, present it | any renderer | nothing extra |

All three compute the same formula:

```
out = (in - 127.5) * contrast + 127.5 + brightness
```

`brightness` is 0..255, `contrast` is a multiplier around mid grey where 1.0 is a
no-op.

---

## Headline result

**A and C produce byte-identical output. All three sweep points, both frames,
SHA-256 equal.**

```
b0_c1.00:  IDENTICAL  56d9b2f7...
b40_c1.00: IDENTICAL  a7e72a37...
b0_c1.40:  IDENTICAL  bdd6af20...
```

`metrics.csv` records `mean_delta_vs_A = 0.0000`, `max_delta_vs_A = 0`,
`pct_pixels_differ = 0.0000` for every C row against its matching A row.

That is not a bug in the POC, it is the finding. C is the same arithmetic with an
extra buffer and a different presentation point. **C's only real purchase is a
clean place to hang further post effects**, and it costs one more full-size buffer
(800x640 RGB ≈ 1.5 MB per frame of allocation churn if not reused).

**Method B could not be exercised.** See below. Its output is unmeasured and no
claim is made about it.

---

## Method B: unavailable on this machine

Verbatim from the run:

```
loadShader(), or this particular variation of it, is not available with this renderer.
[poc] SHADER LOAD FAILED: java.lang.RuntimeException: createGraphics() with P2D requires size() to use P2D or P3D
[poc] method B UNAVAILABLE - no GL context.
```

`poc/gl_probe/` isolates this. It requests `size(W, H, P2D)` and tries to render one
known pixel through the same shader. The JVM dies with **exit 133 (SIGTRAP)** before
printing a single line, headless and non-headless alike, once JOGL's native
libraries are on the classpath. No GL context is obtainable here.

`system_profiler` reports the built-in panel as `Display Asleep: Yes`. An external
1600x900 display is present and online.

Two things worth carrying into the CR:

1. **`loadShader()` does not fail loudly.** It returns a `PShader` whose program
   never compiled. Without the pixel probe in `poc_filter.pde`, method B would have
   written plausible-looking PNGs that were simply the unfiltered input. Any
   production use needs the same probe.
2. **`createGraphics(w, h, P2D)` throws unless `size()` already used P2D.** So method
   B cannot be confined to an offscreen buffer — it forces the **main** canvas onto
   P2D. That changes font AA, line AA and `image()` smoothing for the whole sketch,
   which is a far larger visual change than brightness/contrast. This cost was
   predicted before the POC and is confirmed by the API, not measured.

To exercise B: open `poc/poc_filter/` in the Processing IDE and Run.

---

## Measured effect on the frames

Red channel, over every pixel. `mean` is the average — on a near-black frame it
moves more than `max` does, which is the whole point of the brightness knob.

### `frame_native_800x640` (800x640, single display, near-black)

| Output | max | mean | nonzero px | px >= 250 |
|---|---|---|---|---|
| baseline, no bloom | 146 | 1.25 | 15.31% | 0 |
| **+ bloom only** | 165 | 1.63 | 15.34% | 0 |
| A/C `b0 c1.00` | 165 | 1.63 | 15.34% | 0 |
| A/C `b40 c1.00` | **205** | **41.63** | **100.00%** | 0 |
| A/C `b0 c1.40` | 180 | **0.23** | **0.57%** | 0 |

Bloom moves peak 146 → 165 and nothing else. At `b40` the frame goes from 15% lit
pixels to 100% — the black floor lifts to a visible dark grey, and **no pixel
clips**. At `c1.40` the opposite: 15.31% → 0.57% nonzero, mean drops 7x. Contrast
around 127.5 crushes a near-black frame hard, because there is almost nothing above
the pivot to expand.

### `frame_composite` (1792x1124, full 9-display composite)

| Output | max | mean | nonzero px | px >= 250 |
|---|---|---|---|---|
| baseline, no bloom | 249 | 9.56 | 56.95% | 0 |
| **+ bloom only** | 255 | 14.77 | 57.80% | **6233** |
| A/C `b0 c1.00` | 255 | 14.77 | 57.80% | 6233 |
| A/C `b40 c1.00` | 255 | **54.62** | **100.00%** | **11713** |
| A/C `b0 c1.40` | 255 | **8.55** | **11.58%** | **10810** |

This frame behaves very differently from the first:

- **Bloom alone already clips 6233 pixels** to 255, and drives max from 249 to 255.
  Bloom's ADD pass is doing highlight work before any brightness knob exists.
- **`b40` nearly doubles the clipped count to 11713** and lifts mean 3.7x.
- **`c1.40` is destructive**: nonzero drops 57.80% → 11.58%, more than half the lit
  pixels go to pure black, while 10810 pixels *also* clip at the top. Contrast on
  this frame is a black-and-white poster, not a richer image.

**`contrast` around mid grey is the wrong pivot for this content.** Both frames are
80–95% black. A pivot at 127.5 expands a range almost nobody occupies. Whatever
gets chosen, the CR should treat contrast as a *narrow* knob and brightness as the
main one — `b40` is the setting that reads as an improvement, `c1.4` reads as damage.

*(Numbers are from my own PNG reader in `/tmp`, not from a Processing API. They are
counts over the red channel only.)*

---

## Seed frames

Both copied from the repo. **Provenance is unrecorded** — I did not capture these and
am not claiming what renderer, commit or bloom state produced them.

| file | source | size |
|---|---|---|
| `data/frame_native_800x640.png` | `DisplaySubWindows.png` | 800x640 |
| `data/frame_composite.png` | `readme.png` | 1792x1124 |

To use a real current frame instead, drop it in `data/` and add it to `FRAMES` in
`poc_filter.pde`.

---

## What this POC does not answer

- **How it looks.** F-1: I cannot see the window. The images in `out/` are for your
  eyes. Every number above is counted from pixels, not judged.
- **Temporal behaviour.** A static frame cannot show per-frame contrast amplifying
  audio noise or flicker. On a live audio-driven sketch, `c1.4` may be far worse
  than these numbers suggest.
- **Cost.** Nothing here is timed. The CPU loop is 512k px/frame at 800x640; that is
  a guess, not a measurement.
- **Method B.** Unmeasured. See above.
- **Export.** `videoExport.saveFrame()` reads the main canvas, so the pass must land
  before it for preview and export to match. Not tested — `RECORD_VIDEO` is false.

---

## Files

```
poc_filter.pde        orchestration, sweep, metrics
PocFilter.pde         the filter itself (cpuPass, shaderPass)
PocBloom.pde          bloom lifted from BloomPProcess.pde, source passed as a param
data/poc_bc.frag      method B shader
out/                  results, 16 PNGs + metrics.csv
gl_probe/             standalone P2D probe, reports and exits
```

`PocBloom` exists because `BloomPProcess` reads the main canvas (`loadPixels()` with
no argument) and draws back onto it with `blendMode(ADD)`. A reusable post pass
needs to take a source image. **That refactor is a prerequisite for the CR**, and it
is a change to `BloomPProcess.pde`.

---

## Build note

Run from the Processing IDE: `open -a Processing poc/poc_filter`.

This was instead compiled headless, because `processing-java` on this machine is
broken (it points into an `AppTranslocation` path that no longer exists). The POC was
driven through `PdePreprocessor` + `javac` directly. That build driver lives outside
the repo in a temp directory, not committed, so this workspace still has no build
file.

Along the way, four real Processing 4 facts, each of which cost a build cycle:

1. `PApplet.brightness(int)` reads `colorMode` off the graphics object and NPEs when
   it is null. The bloom threshold now computes luma directly.
2. `PShader.setUniform(String, ...)` is **protected**. The public API is `set(...)`.
3. `PGraphics` ignores draw calls made outside `beginDraw()`/`endDraw()`. The
   additive bloom blit was silently drawing nothing until this was fixed.
4. `savePath()` resolves against the sketchbook, not the sketch. Output landed in
   `/Applications/out` before this was corrected — that stray directory has been
   removed.

These are all POC-local. None of them is a change to the sketch.