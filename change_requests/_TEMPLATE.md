---
status: draft
author: norsez
date: YYYY-MM-DD
scope: <one-line summary of the change>
principles_checked: <Floor Rules this change touches — see AGENTS.md §Floor Rules>
---

# <Change Request Title>

## Why
- <the problem or goal driving this change>

## What / How
- <what will change, which .pde tab, and how — specific enough to grill against the floor rules>

## Does this change what appears on screen?
- [ ] No — pure refactor, behaviour identical. This request is informational.
- [ ] Yes — a flag default, a display added or removed, a smoothing factor, a threshold, a frame rate.

> A "Yes" here is what makes this a change request rather than a free refactor. F-5 in `AGENTS.md`.

## Dependencies
- [ ] No new library, no new asset in `data/`
- [ ] New library or new asset — name it, and say whether it is committed to `data/`

## Out of Scope
- <what is explicitly NOT changing>

## Acceptance Criteria
- [ ] verifiable outcome — for this stack, usually "opens in the IDE and runs"

## Principle Check
- Which Floor Rules (F-1…F-5) this touches, and confirmation of no conflict — or the exact violated
  rule if rejected.
- F-3: if a tab, a `data/` file, or the sketch folder name is renamed, say so here. That is never a
  side effect of a refactor.