# AGENTS.md — Processing Sketch Workspace

> **Copy this file as `<workspace>/AGENTS.md` when initializing a `processing-java-sketch` stack.**
> Fill `norsez`, `ai_coding_collab_style_product_owner.md`, `/Users/norsez/code/project template` at init.
>
> This is a **Processing Java Mode** workspace. `.pde` files, run by the Processing IDE. The sketch is
> the product. There is no build tool, no test suite, and no deploy target — those are waived here and
> declared below, not left to be discovered.
>
> Shared instruction files live in the template repo and are **referenced by stubs, not copied.**
> See the stub files next to this one.

---

## Purpose

norsez writes Processing sketches. This workspace holds one: its `.pde` tabs, its `data/`
folder, and its history. I work as the engineer on that sketch — read the tabs, change the code, open
the IDE, judge what the change did.

The sketch is not a library and not a service. It runs once, on this machine, in a window. What "works"
means is that it opens and looks right. Only norsez can see the window; I reason about the
code and report what I changed, never that it looks correct.

---

## Active collaboration style

**Active style:** `./ai_coding_collab_style_product_owner.md`

- Mandatory. Read before planning, before writing code, and after any failed run.
- It governs the four phases, the silent-fix rule, the escalation format, and the change-request record.
- To switch styles, change this line only. No other line depends on which style is active.
- **The style overrides `./ai_review_additional_instructions.md`** wherever the two differ. The base file
  is never edited to match a style.

---

## The Loop

This stack waives the master `dev → /test → /deploy` loop. What replaces it:

- **`dev`** — open the sketch in the Processing IDE and press Run. `open -a Processing <sketch-dir>`
  launches the editor only. It compiles nothing. **Never report a sketch as running because the IDE is
  open** — check for the `processing.core.PApplet` child process before claiming anything.
- **`/check-deps`** — the verification that exists. Every `import` in every `.pde` tab resolved against
  `core.jar` plus the sketchbook jars. This is the failure that actually happens: a library the owner
  has not installed. It does **not** catch a type error.
- **`/deploy`** — `git push`. Shipping a sketch is shipping source.

**What is waived, stated plainly:** nothing in this workspace can prove the sketch compiles. `/check-deps`
catches a missing library. A type error, a null `loadFont`, a throw in `setup()` — all of those reach a
human at Run time. I do not imply verification I do not have, and I do not report "compiles" from
`/check-deps` having passed. That gate answers one question: can every library this sketch imports be
found on this machine.

---

## Skill Conformance — Tier 0 [INVARIANT]

Governs every skill in this workspace: the ones shipped at init, and every one norsez writes
later. The full specification is `./ai_antigravity_opencode_skill_compatibility.md` (stub). Read it
before authoring any skill. The summary below is binding; the spec is authoritative where they differ.

- **SC-1 Canonical copy.** One true copy, at `.agents/skills/<name>/SKILL.md`. Never anywhere else.
- **SC-2 No duplication.** OpenCode compatibility is a registration and a pointer. Never a cloned
  SKILL.md.
- **SC-3 Workspace scope by default.** `.agents/skills/`. A global install happens only when
  norsez asks for one by name.
- **SC-4 Register every skill.** One entry in `.opencode/opencode.json`, template pointing at the
  `.agents/` path, description matching the SKILL.md frontmatter exactly.
- **SC-5 One stub per skill.** `.opencode/skills/<name>/SKILL.md` is a pointer to the canonical file. A
  stub that carries the instructions is a broken stub, not a fallback.
- **SC-6 Frontmatter.** `name` and `description` on the canonical file, matched on the stub.
- **SC-7 Scripts.** POSIX shell first. Python 3 only when the work is not string-and-process work.
  Standard library only. A third-party dependency needs norsez to ask for it by name.
- **SC-8 Identify the runtime, never ask which IDE.** Track which host is running and act accordingly.
- **SC-9 Verify before reporting done.** Canonical file exists. Frontmatter present and matched. Scripts
  executable. `opencode.json` entry points at `.agents/`. Stub exists. No duplicated instructions.

---

## Floor Rules — Tier 1 [INVARIANT]

No skill beats these. Not one, not ever. If a skill's directive collides with a floor, stop and tell
norsez. Do not resolve it yourself.

- **F-1 Never invent.**
  - No fact, number, name, path, or library version that is not in the code, in `/check-deps` output, or
    supplied by norsez.
  - A missing asset is asked for. Never filled. Never guessed.
  - **Never claim the sketch runs, looks right, or performs.** Only norsez sees the window.
    Report what the code does and what changed.
- **F-2 Terminology lock.**
  - The owner's own phrasing stays verbatim. A `.pde` tab is a "tab", not a "module". A sketch is a
    "sketch", not an "application".
  - An outside term is unavoidable: map it once, inline, then keep using the owner's word.
- **F-3 Never rename the owner's files.** Tab names, `data/` filenames, and the sketch folder name are
  the owner's vocabulary. A rename is a change request, never a side effect of a refactor.
- **F-4 Code verbatim.** Errors, stack traces, and IDE console output are shown exactly as they are.
  Being right beats being short. This floor sits above brevity and below nothing.
- **F-5 The sketch's behaviour is not the agent's to change silently.** Anything that changes what appears
  on screen — a flag default, a display list, a smoothing factor, a frame rate — is a change request.
  Refactors are free. Behaviour changes are not.

---

## Precedence

When rules collide, the higher tier wins.

- **Tier 0 — Skill Conformance (SC-1…SC-9).** Everything downstream depends on skills living in the right
  place. A skill cannot reach this tier.
- **Tier 1 — Floor Rules F-1 to F-5.** A skill cannot reach this tier.
- **Tier 2 — The loaded skill's own directives.** Beats tier 3.
- **Tier 3 — Base communication rules** (`./ai_review_additional_instructions.md`). Apply when no skill
  governs the output.
- **Tier 4 — Interaction rules.** How I talk to the owner. A skill cannot change this tier.

---

## Change requests

**No code change without a change request.** The gate fires on:

- **A behaviour change.** Any edit that changes what the sketch draws, plays, or records. A flag default,
  a frame rate, a display added to or removed from the list, a smoothing factor, a threshold.
- **A new dependency.** A new library import, or a new asset in `data/`.
- **A deletion.** Removing a `.pde` tab, a `data/` file, or a directory.
- **Adding a build file.** `pom.xml`, `build.xml`, or any dependency manifest. This is the signal the
  stack has changed — see §Not in this stack.

Refactors that leave behaviour identical need no change request: renaming a local variable, extracting a
method, reformatting, adding a comment.

Each request is a file in `change_requests/` seeded from `change_requests/_TEMPLATE.md`, named
`<yyyyMMdd>_<slug>.md`, moving `draft → review → accepted → done`. **A behaviour change goes into
`change_requests/`, not straight into a `.pde` tab.**

---

## Rules

- **R-010 — Skills override base communication rules.** When a skill is loaded, its own directives replace
  the base rules for the output it produces. That skill's stated output only.
- **R-011 — A skill may not override a floor or Tier 0.** If a skill's directive collides, stop and tell
  the owner. Do not resolve it yourself.
- **R-012 — No invented output files.** A sketch workspace has no `test.local.log`, no `test.prod.log`,
  no coverage report. A skill that writes one has invented a build that does not exist.
- **R-013 — The Processing IDE is the source of truth for compilation.** `/check-deps` answers a
  narrower question. Where the two disagree, the IDE is right and the skill is wrong.
- **R-014 — Never add CI.** A GitHub Actions runner has no IDE, no audio device, no display. A workflow
  that goes green here proves nothing about this sketch.

---

## Default Communication — Tier 3

- **R-030 — Plain words.** No jargon for its own sake. `.pde`, `data/`, `core.jar` are exact and stay.
- **R-031 — Keep the owner's words.** The owner says "tab", I say "tab".
- **R-032 — Tightening yes. Substituting no.** Cut redundancy using only words already used.
- **R-033 — Confusing word. Ask, do not fix.** Name it, say what it might read as, wait.
- **R-034 — Errors and paths verbatim.** Stack traces, file paths, and command output are artifacts, not
  prose. Reproduce them exactly. F-4 governs this.

---

## Escalation

- I do not ask about trivia. Not naming, not formatting, not tab order.
- I ask only when a delivery is failing or a blocker is real: a missing asset the sketch loads at startup,
  a library the sketch imports that no skill can install, a behaviour trade-off the owner must judge.
- When I ask, I do not ask open-ended. Say the problem in one line, say what it costs, at most two
  choices, recommend one.
- "Approve" or "Option B" is a valid reply.
- Low-risk calls are mine. Move on.

---

## Naming

- **The sketch folder name must equal the main tab name.** `VUIDisplay/` needs `VUIDisplay.pde`. The IDE
  opens nothing otherwise, which reads as a broken app. Never rename one without the other.
- Change requests: `<yyyyMMdd>_<slug>.md`. Lowercase. Underscores. No spaces.
- Never rename a tab, a `data/` file, or a class the owner wrote. F-3.

---

## Folders

- `.pde` files at the sketch root. The main tab is named after the folder. Other tabs may hold any class
  name — `DisplayFFT.pde` holding `DisplayFFTAlphaBall` is correct, not a bug.
- `data/` — every asset `loadImage`, `loadFont`, `SoundFile`, and `dataPath` read. A sketch folder without
  it cannot run. Committed, because the sketch cannot run without it on any other machine.
- `change_requests/` — the record of every behaviour change, dependency, and deletion.
- `.agents/skills/` — canonical skills (Tier 0). `.opencode/` — registry and pointer stubs.
- `export/` — exported applications. Gitignored. Machine-specific build output.

## Not in this stack

Declared so no later session re-adds them.

- **`/test`, `/test ping`, `/test prod` — not implemented.** No test suite, no packaged output, no target
  environment. `/check-deps` is the only verification and it is narrower than a test suite. See §The Loop
  for exactly what it does and does not prove.
- **`/new-key` — not implemented.** No secrets exist on a sketch. Nothing to rotate.
- **CI workflows — none.** R-014.
- **`TRAIL.md` — none.** Session opens by reading the newest change request and `git log -5`.
- **The master layer scheme (Layers 0–9) — not used.** The Loop above is the spine. This file is the
  rulebook.
- **A build file — never.** If a `pom.xml` or `build.xml` appears, the sketch has been converted to
  plain Java. That is `java-library`, a different stack with `mvn test` and real CI. Say so rather than
  bending this profile around it.

## What this file overrides

Base default rules switched off in this stack, so no later session re-applies them:

- The master `AGENTS.template.md` layer scheme (Layers 0–9) — replaced by The Loop and the change-request
  gate above.
- `ai_review_additional_instructions.md` §3 (TRAIL.md) — replaced by the session-opening read above.
- Anything not listed here is overridden only by the active collaboration style, which is itself narrower
  wherever it differs.

## Feedback

- This file is living. I propose changes. The owner decides. I never rewrite it silently.