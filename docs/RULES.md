# RULES — Kid-Bait Physics Toy

Standing rules for every build session (Muse, Claude, or Urbish himself).
Violate one → the phase's tests fail by definition.

## Docs-first (vibe-coding playbook)
1. Read PRD.md, ARCHITECTURE.md, DESIGN.md, RULES.md, TASKS.md, DECISIONS.md
   before touching code. No code until the implementation plan is approved.
2. One task at a time (TASK-00x). Understand → Plan → Implement → Test →
   Review → Commit → next. Never "build the whole thing" in one prompt.
3. Docs are living: TASKS.md, MEMORY.md, DECISIONS.md, ARCHITECTURE.md get
   updated as the project changes. Never let docs describe an app that no
   longer exists.
4. Completion reports use the playbook format: files changed / what was
   implemented / tests executed / remaining issues.

## Modularity (load-bearing)
5. NEVER hardcode content into core scripts. New character/obstacle/arena =
   new module folder + manifest. Core edits to add content = failed review.
6. Every module ships `module.json` (valid schema), a root scene implementing
   the content interface, default params, and a `preview.png` from the render
   smoke test. `manifest_check.py` fails the build otherwise.
7. Presets are data (`presets/*.json`), not code. The staging UI edits them.

## Performance (hard, linted)
8. Every model ≤3k tris; scene ≤100k tris; ≤60 dynamic rigid bodies —
   `tri_lint.py` runs on every test pass, no exceptions.
9. Lambert-equivalent materials only; 1 dir + 1 hemi light; NO shadow maps
   (blob shadows); NO post-processing.
10. Rigid bodies ONLY. No soft-body, no cloth — ever.

## Legal & assets
11. Characters: archetype + 20–30% geometry change + OWN names + no brand
    marks. Keep a per-character difference log. (ADR-007)
12. Audio: Suno chants live in `assets/chants/` isolated for swap-out;
    never ripped audio. (ADR-008)
13. Kenney assets are CC0 — keep the license file with the assets.

## Testing (ADR-011)
14. Every feature: unit test (GUT) where logic is pure + render smoke test
    (scripted input, screenshots, visual inspection) + his manual playtest
    per phase. "It compiled" is not done.
15. Nothing is handed to Urbish until everything is green on jarvish
    (standing test-first rule).

## Git & machines
16. Git from the first change; small commits; every commit gets its own
    distinct descriptive message (his standing rule).
17. Repo is PRIVATE and stays private. Never flip visibility.
18. Build + test + render ALL happen on jarvish (`~/kid-toy-factory/`).
    The ASUS is async confirmation only (TASK-901) — never a gate, never a
    blocker. (His correction, 2026-10-15.)
19. One-heavy-job-at-a-time on jarvish during renders. Overnight batch OK.
20. $0 budget: free libraries, CC0 assets only. No paid services.

## His standing rules (apply here too)
- Terse output by default; warn before context-heavy work.
- Look up how-to steps from current sources — never vague from memory.
- Verify against the actual code/page, never generate from memory.
- Design-first: staging UI gets mockups before Godot UI code.
- Structured bug reports (ERROR / EXPECTED / ACTUAL / STEPS / CONSTRAINT);
    root-cause first, smallest fix, no unrelated refactors.
