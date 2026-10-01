# VUIDisplay

A music visualiser written in Processing 4 (Java Mode).

Inspired by the synth jam posts on Instagram with the cute minimalist graphics that accompany
brilliant short synth jam patterns. I write this visualiser to visualise my own synth jam posts.

Below are example screenshots (with a little bit of bloom effect). Click a screenshot for a video.

[![VUIDisplay](https://github.com/norsez/VUIDisplay/raw/main/readme.png)](https://www.youtube.com/watch?v=QH8t0uytZyU)

## How to run it

The sketch is `.pde` files run by the Processing IDE. There is no build step and no package to
install.

- Install Processing 4 — <https://processing.org/download>
- Install the libraries the sketch imports: **controlP5**, **VideoExport**, **sound**. Do this through
  Sketch → Manage Libraries, not by dropping jars in.
- Open the folder in the Processing IDE and press Run.

Verify step 2 first without launching anything:

```
/check-deps
```

It resolves every `import` in the sketch against `core.jar` and the sketchbook, and reports the ones
that are missing. This is the failure you hit on a fresh machine.

> **Libraries are not vendored in this repository.** A fresh clone cannot compile until they are
> installed. This is deliberate — see `AGENTS.md` §Local config & secrets.

## How the sketch is organised

| Piece | What it is |
|---|---|
| `VUIDisplay.pde` | Main tab. `setup()`, `draw()`, the display list, the flags |
| `data/` | Every asset the sketch loads — fonts, images, the audio file |
| `Display*.pde` | One tab per display type. Each draws into a `PGraphics` |
| `Layout*.pde` | Arranges the displays on screen |
| `AudioInput.pde` | Loads the audio file, feeds loudness and the frequency bands |
| `StateController.pde` | Sequences display changes over time |
| `BloomPProcess.pde` | The bloom pass. Off by default — it is expensive |

**The main tab must be named after the folder.** `VUIDisplay.pde` in `VUIDisplay/`. The IDE opens
nothing otherwise, and it reads as a broken app.

## Keyboard

Handled in `keyPressed()` in `VUIDisplay.pde`.

| Key | What it does |
|---|---|
| `1`–`9` | Show or hide that display. Number order matches the list built in `initDisplays()`: laser paint, bar waveform, beta ball, bouncing laser, wave, FFT balls, running wave, wave DNA, spectrum bars |
| `Space` | Freeze the drawing. Audio keeps playing — only `layout.draw()` is skipped, so the visuals hold still while the sound runs on. Useful for grabbing a clean frame |
| `A` `B` `C` `D` | Pick which control the scroll wheel moves. Each is 0–128, then scroll to change it. Press a letter again to switch. Every display maps these four to its own parameters — this is the main live-performance control |
| `X` | Zero all four controls and bang every display. Bang is each display's "something changed, react" hook. Effectively a reset |
| `H` | Show or hide the `controlP5` panel. It starts hidden |
| `W` | Toggle `DEBUG`. Gates the debug overlays in `Debug.pde`, and text in `DisplayTitle.pde` and `SelfDrivenTile.pde` |
| `Q` | Stop recording and exit. **Only works when `RECORD_VIDEO` is true.** A hard `exit()`, so a stray press during a recording ends the sketch |
| `Z` | Toggle auto layout. **Currently does nothing visible** — `isAuto` is only read by `LayoutAllInOne`, and the active layout is `LayoutWithFixedDisplaySet` |

## Performance notes

Two costs dominate, and both are already off by default:

- `APPLY_BLOOM` in `VUIDisplay.pde` — a full-screen brightness scan plus a separable blur, every
  frame, at 800×640.
- `FFT_NUM_BANDS` in `AudioInput.pde` — 512 bands analyses the whole spectrum. 256 is
  near-indistinguishable and half the cost.

Turn either back on deliberately. Both are a change request, not a default.

## Where the work happens

- `AGENTS.md` — the rulebook. What the loop is here, what is waived, and why.
- `SKILLS.md` — what `/run` and `/check-deps` are for.
- `change_requests/` — every behaviour change, new dependency, and deletion.