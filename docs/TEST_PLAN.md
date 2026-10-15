# TEST_PLAN — Kid-Bait Physics Toy

How we verify. "It compiled" is never done. Every phase's definition of
done includes its level(s) below, green.

## Level 1 — Static checks (every commit, jarvish)
- `tri_lint.py` — every model ≤3k tris, scene ≤100k tris. Fail = block.
- `manifest_check.py` — every module has valid module.json, root scene
  loads, content interface present. Fail = block.
- GDScript parse check (`godot --headless --check-only` per script or
  editor import). Fail = block.
- No secrets in repo (grep for keys/tokens in CI script). Internal tool,
  but private repo hygiene anyway.

## Level 2 — Unit tests (GUT, `tests/unit/`)
Pure logic only: VariationEngine sampling (≥4 axes differ, seeds
reproducible), ContentRegistry validation (good/bad manifests),
preset schema migration, beats-timeline math. Run headless on jarvish.

## Level 3 — Render smoke tests (jarvish, Xvfb + `--rendering-driver opengl3`)
The "actual UI-based interaction" layer:
- Boot a scenario scene headless-under-Xvfb; drive the staging UI with
  scripted `Input.parse_input_event` sequences (browse → load preset →
  tweak param → record 5s).
- Capture screenshots every N frames via viewport texture → PNG.
- **Muse reads the PNGs** and verifies: arena renders, cars present with
  faces, destroyer slams, squash tween fires, no pink/missing materials,
  UI usable at each step.
- Any visual defect → structured bug report (RULES), root-cause first.

## Level 4 — Recorded-clip verification (ASUS, per phase)
- `tools/record.sh` output checked automatically: resolution exactly
  1080×1920, 30fps, non-silent audio track, `wall_avg` logged.
- Urbish watches the clip: hook in first 2s? faces readable? comedy
  timing right? His approval is the gate.

## Level 5 — His manual playtest (ASUS, end of every phase)
Per the playbook: he runs the build himself on his laptop. Staging speed
(<2 min to a render), module-drop test (new folder, no core edits), and
general feel. His explicit approval closes the phase.

## Regression policy
Every fixed bug gets a test (unit or render) that would have caught it.
`tests/` grows monotonically; never delete a regression test to make a
phase pass.

## Perf regression
`wall_avg` per rendered second is logged per phase. If it regresses >20%
between phases, stop and profile before adding features.
