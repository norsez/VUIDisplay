# SKILLS.md

Registry of every skill in this workspace.

- 2 skills at init. New ones appear when the owner asks for a capability.
- Canonical copy lives in `.agents/skills/<name>/SKILL.md`.
- `.opencode/skills/<name>/SKILL.md` is a pointer stub. Never a copy.
- Tier 0 (SC-1…SC-9) in `AGENTS.md` governs storage. No skill is registered twice.
- Never add a skill unasked.

## The two

- **`/run`** — Opens the sketch in the Processing IDE and reports whether the sketch process
  actually started. It does not press Run and it does not compile.
  - For: opening the sketch, confirming the IDE has it, confirming a previous run is
    still alive or has died.
  - Not for: building, testing, verifying code. It cannot do any of those.

- **`/check-deps`** — Parses every `import` in every `.pde` tab and resolves each against
  `core.jar` plus the sketchbook libraries. Reports the imports that cannot be found,
  naming the jar it looked for.
  - For: a fresh clone, a newly added library, a compile error that names a package
    rather than a library, before Run.
  - Not for: proving the sketch compiles. It does not preprocess and it does not
    type-check. It answers one question only — is every library this sketch imports
    present on this machine.

## What does not exist here

- **`/test`** — no test suite. A `.pde` sketch has no unit under test without being
  rewritten as plain Java, which is a different stack.
- **`/deploy`** — shipping is `git push`. A skill wrapping it earns nothing.
- **`/new-key`** — no secrets on a sketch.

## Adding skills

When a recurring need shows up, ask the AI in plain words. Storage is Tier 0: canonical in
`.agents/skills/`, one `opencode.json` entry, one pointer stub.