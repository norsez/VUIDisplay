---
status: done
author: norsez
date: 2026-10-03
scope: Tighten audio-driven motion sync by reducing smoothing latency and removing param update throttling
principles_checked: F-1, F-2, F-3, F-5
---

# Tighten audio sync (less lag / grinding)

## Why
- Sync feels lagging and sometimes grinding slowly when motion is driven by audio (amp/FFT/waveform).
- Root causes:
  - `smoothingFactorAmp = 0.25` in `AudioInput.pde` creates heavy 1-pole smoothing → ~150-250ms lag on peaks.
  - `APP_PARAM_UPDATE_RATE = (APP_FRAME_RATE * 0.25)` in `Util.pde` throttles many param updates to every 4 frames (~167ms) → stepped/grinding response.
  - Compounding: `ParamSmoothener`, Easing, LFO speed updates inherit throttled/timed values.
  - Potential track mismatch: `FILENAME="Thai elephant.wav"` but repo contains `Norsez 15.2.wav`, `Norsez 17.wav`, `Norsez 18.2.wav`.

## What / How
- **AudioInput.pde** (audio smoothing):
  - Change `smoothingFactorAmp` from `0.25` to ~`0.7` (tune 0.6–0.8).
  - Change `smoothingFactorFFT` from `0.75` to ~`0.9` (tune 0.85–0.95).
- **Util.pde** (throttling):
  - Set `APP_PARAM_UPDATE_RATE = 1` (or `(long)1`) so `shouldUpdateParams()` allows updates every frame.
- **Optional (verification):** If playing a Norsez track, update `FILENAME` in `AudioInput.pde` to match the actual file in `data/` (e.g. `"Norsez 18.2.wav"`).

## Does this change what appears on screen?
- [x] Yes — changes timing/sensitivity of motion response to audio (smoothing factors, update cadence). Behaviour of visual output changes.

> This is a change request per F-5 (behaviour-affecting timing/response). Refactors only if values kept identical.

## Dependencies
- [x] No new library, no new asset in `data/`
- Existing assets: `data/*.wav`, `data/*.vlw`, `data/*.jpg` remain unchanged.

## Out of Scope
- Changing display algorithms, layout, colors, or adding/removing displays.
- Changing frame rate (`APP_FRAME_RATE`) unless later testing shows need.
- Renaming files/tabs/folder (F-3 preserved).

## Acceptance Criteria
- [ ] Sketch opens in Processing IDE and runs without errors.
- [ ] Motion feels tighter to audio transients (less lag), stepping/grinding reduced.
- [ ] No obvious increase in visual jitter beyond acceptable after tuning (can dial back values if needed).
- [ ] If track filename changed, audio loads correctly from `data/`.

## Principle Check
- F-1: Changes are based on observed code values (AudioInput.pde, Util.pde, shouldUpdateParams usage). No invented deps/assets.
- F-2: Uses existing terms ("tab", "sketch", `.pde`, `data/`) — no substitution.
- F-3: No renames of tabs, data files, or sketch folder.
- F-5: Yes, affects on-screen motion response (timing); recorded as CR.
- No conflict with Floor Rules.