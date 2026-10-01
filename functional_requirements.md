# functional_requirements.md — VUIDisplay

Source of truth for **what this sketch does**. `AGENTS.md` is the source of truth for how work happens
here. A change to either is a change request.

## 1. What it is

A music visualiser. A Processing 4 sketch (`.pde`, Java Mode) that plays an audio file and draws
reactive graphics driven by that audio. Written to accompany synth jam posts — short instrumentals
posted as video with minimal graphic overlays.

The output is a window, and optionally a recorded video. Not a service, not a library, not a
deployable.

## 2. Audio input

One audio file, read from `data/`, currently `Thai elephant.wav`. It loops.

| Signal | Source | Used by |
|---|---|---|
| Loudness | `rms.analyze()`, smoothed at `smoothingFactorAmp` | Ball size, alpha, stroke weight, tile size, ruler speed and tint |
| Frequency bands | `fft.analyze()`, smoothed at `smoothingFactorFFT` | The frequency-bar field, the spectrum display |
| Waveform | `waveform.analyze()`, 64 samples | Bar waveform, running wave, DNA double helix |

Fourteen tabs read at least one of these. **Nine of the nine active displays scale on loudness or
waveform** — removing the audio input removes the product.

`FFT_NUM_BANDS` is 256. It was 512. The lower value is a deliberate performance choice; the full
spectrum analysis cost twice as much for no visible difference.

## 3. The display system

A display is anything implementing `DisplayInterface`. It draws into a `PGraphics` and can be shown or
hidden. Nine are created at startup, in this order:

| # | Display | What it draws |
|---|---|---|
| 1 | `DisplayLaserPaint` | Points tracked across a cycling set of 14 images |
| 2 | `DisplayBarWaveForm` | A bar per waveform sample, eased |
| 3 | `DisplayBetaBall` | Bouncing ball, size driven by loudness |
| 4 | `DisplayBouncingLaser` | Laser with speed and size driven by loudness |
| 5 | `DisplayWave` | A waveform curve across the screen |
| 6 | `DisplayFFTAlphaBall` | One ball per frequency band |
| 7 | `DisplayRunningWave` | A wave running along the top edge |
| 8 | `DisplayWaveDNA` | A double helix built from the waveform |
| 9 | `DisplaySpectrumBars` | Spectrum bars, alpha scaled by loudness |

`LayoutWithFixedDisplaySet` arranges them. Each display has a keyboard toggle (number keys 1–9) and a
`controlP5` toggle in the hidden control panel.

## 4. Frame pacing

`Util.pde` owns the update cadence. `tickAllRates()` counts frames; `shouldUpdateParams()` is true
every `APP_PARAM_UPDATE_RATE` frames (24 fps ÷ 4). Nine displays gate their parameter reads on it, so
parameters update at 6 Hz while the sketch draws at 24 Hz.

**This replaced inline `frameCount % APP_PARAM_UPDATE_RATE` checks.** The behaviour is the same; the
arithmetic now lives in one place.

## 5. Control

Four control values, `controlA` through `controlD`, each 0–128, driven by `controlP5`. Every display
maps these to its own parameters. `LayoutWithFixedDisplaySet` can also drive `controlA` from two LFOs.

## 6. State sequencing

`StateController.pde` holds a `StateSequenceController` — an ordered list of states with frame
durations. When a state expires it fires its callbacks and advances. This is how display changes are
choreographed over time.

## 7. Video recording

Off by default. `RECORD_VIDEO` in `VUIDisplay.pde`, using the `VideoExport` library. `RECORD_SECS`
holds the length. When the frame count is reached it writes the file and exits.

## 8. Performance

Two costs dominate. Both are off by default and each is a change request to change.

| Flag | Default | Why |
|---|---|---|
| `APPLY_BLOOM` | `false` | A full-screen brightness scan plus a separable blur, every frame, at 800×640 |
| `FFT_NUM_BANDS` | `256` | Full-spectrum analysis at 512 bands cost double for no visible difference |

## 9. Not in this product

- **MIDI playback.** Removed. `AMidiPlayer.pde` and `DisplayTestNotes.pde` are gone. The code was
  unreachable — nothing assigned the player, called the tick, or instantiated the display — and the
  file it loaded, `data/Norsez 18.3.mid`, did not exist on any machine, so `load()` caught the failure
  and called `exit()`. The sketch died at startup.
- **A test suite.** See §10.
- **CI.** A runner has no IDE, no audio device, and no display.
- **A deployed URL.** There is none.

## 10. Verification, stated honestly

Nothing in this workspace can prove the sketch compiles.

`/check-deps` resolves every library the sketch imports against `core.jar` and the sketchbook. That
catches the failure that actually happens on a fresh clone — a library that is not installed. It does
**not** preprocess, compile, or type-check.

A type error, a null `loadFont` from a missing asset in `data/`, a throw inside `setup()` — all reach a
human at Run time. This is recorded here so no later session implies verification it does not have.

## 11. Assets

Everything the sketch loads lives in `data/` and is committed, because the sketch cannot run without it
on any other machine.

| Asset | Loaded by | Failure mode if missing |
|---|---|---|
| `automat-6.vlw`, `04b08-8.vlw`, `Arcade-16.vlw` | `loadFont` in `VUIDisplay.pde` | Null font, sketch dies in `setup()` |
| `chang1.jpg` … `chang14.jpg` | `DisplayLaserPaint` | Point sets never track |
| `Thai elephant.wav` | `SoundFile` | Throws in `setup()`, no window |
| `matrix.jpg`, `emeraldgreen.jpg`, `thaichars.txt`, `sourcecode.txt`, `automat-6.vlw` | Display internals | Partial |
| `Arcade-16.vlw`, `04b08-8.vlw` | `loadFont` | Null font |

`data/` is 73 MB, most of it audio. Git LFS is the standard fix if it keeps growing — a change request,
not an init task.