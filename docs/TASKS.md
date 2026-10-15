# TASKS — Kid-Bait Physics Toy build

One task at a time (playbook §2.2). A task is done when its acceptance
criteria pass AND the tests in TEST_PLAN.md for that phase are green AND
TASKS.md + MEMORY.md are updated. All testing and rendering happens on
jarvish; the ASUS check (TASK-901) is async and never blocks.

## Phase 0 — Infra + capture gate (BEFORE any game code)

- [ ] **TASK-001** Repo + docs on jarvish: `git init ~/kid-toy-factory/`,
  copy living docs into `docs/`, `.gitignore` (.godot/, renders/, *.avi),
  initial commit. *Accept: `git log` shows docs commit; backup cron active.*
- [x] **TASK-002** Godot 4.6 on jarvish: Linux build downloaded
  (`~/tools/godot-4.6/`, verified `4.6.stable.official.89cea1439`, zip
  integrity OK) + export templates installed
  (`~/.local/share/godot/export_templates/4.6.stable/`). Xvfb: NOT in
  repos/sudo-less — extracted from Arch `xorg-server-xvfb` package to
  `~/tools/xvfb-env/bin/Xvfb` (no root needed). Renders use llvmpipe
  software GL (`LIBGL_ALWAYS_SOFTWARE=1`). Helper:
  `tools/xvfb-run-godot.sh`. Smoke test: scripted 3D scene (red box +
  ground + light + camera) ran under Xvfb + `--rendering-driver opengl3`,
  540×960 PNG captured at frame 90 and visually verified by Muse.
  *Accept: screenshot PNG written and readable — PASS.*
- [ ] **TASK-003** Tooling scaffold: `tools/` with `tri_lint.py`,
  `manifest_check.py`, `to_mp4.sh` (ffmpeg → H.264), `record.sh` skeleton,
  `batch_queue.py` skeleton. *Accept: each script has --help and a dry-run.*
- [x] **TASK-004** Test harness: GUT 9.6.1 wired in `tests/harness/`
  (project + `addons/gut`, unit tests in `tests/unit/`, run headless:
  `-s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit` — 2/2 green);
  render smoke test runner `tests/render/run_render_test.sh`
  (PROJECT SCRIPT OUT_PNG → Xvfb + opengl3 → verifies PNG exists; Muse
  reads the PNG for visual verification). NOTE: harness is scaffolding —
  TASK-101 absorbs it into the real game project.
  *Accept: dummy scene passes the full harness end to end — PASS.*
- [x] **GATE-0** Capture gate on **jarvish**: Claude's `kid-toy-spike.zip`
  run under Xvfb + llvmpipe. *PASS 2026-10-15:*
  - 8s check: 1080×1920, 30fps MJPEG, audio pcm_s16le 48kHz non-silent
    (mean −23.4dB, max −0.5dB), wall_avg ≈65ms/frame, frame visually
    verified (60 candy balls + hammer, correct kid-bait look).
  - 60s gate: `out60.avi` 174MB, 1080×1920 @30fps, 60.03s, audio non-silent
    (max 0.0dB boom); rendered in ~131s wall (≈2.2× realtime on software
    GL — ASUS with real Iris Xe will be faster); transcoded to
    1080×1920 H.264+AAC MP4 (60.03s) via ffmpeg.
  - Spike kept at `~/kid-toy-spike/` on jarvish (reference, not repo code).
  - Verdict: Godot 4.6 Movie Maker is the production path. No fallback needed.
- [ ] **TASK-901** ASUS confirmation (NON-BLOCKING, whenever he has time):
  copy a build to the ASUS, stage → record → MP4. *Pass: works there too —
  expected, since jarvish is the weaker machine.* Never blocks development.

## Phase 1 — Toy core (vertical slices, one at a time)

- [x] **TASK-101** Project scaffold: `game/` Godot project (1080×1920
  viewport, stretch canvas_items/expand, fixed 1/60 physics, Jolt),
  folder layout per ARCHITECTURE.md (game/ subdir — see note), ContentRegistry
  autoload (scan → validate → spawn with `apply_params` interface).
  *Accept: registry self-test passes — PASS 2026-10-15, 11/11 checks
  (empty tree clean, bad module flagged, good registered, spawn+params).*
- [x] **TASK-102** Arena module: `content/arenas/day_arena/` — static
  ground, invisible walls, sky, lighting, camera, module.json.
  *Accept: manifest_check + tri_lint green; smoke-test screenshots show the
  arena — PASS 2026-10-15 (3/3 modules lint green, arena visible in renders).
  Deferred to content-polish: blob shadows, preview.png.*
- [x] **TASK-102b** ScenarioRunner (unnamed in plan, required by TASK-109):
  `game/scenes/scenario_runner.tscn` (main scene) reads
  `--preset=res://presets/*.json`, assembles via ContentRegistry (arena +
  destroyer + ball rosters), fires timeline beats, quits at duration.
  *Accept: 60s spike-equivalent render from JSON, zero code change — PASS
  2026-10-15: 1080×1920 @30fps, 5/5 beats, non-silent audio, 138s wall.
  Physics verified: hammer smash contacts + squash confirmed.*
- [ ] **TASK-103** Asset intake: Kenney Car Kit (CC0) → pick 5 cars,
  tri-count each (≤3k), candy recolor material-override test, face-decal
  quad (angry/happy/dizzy variants). License file kept.
  *Accept: 5 car modules under content/vehicles/, all lint green.*
- [ ] **TASK-104** Moon-ball car: sphere body + 4 wheels, sphere collider,
  squash tween hook, dizzy-face swap on hard hit (2s).
  *Accept: drop test shows squash + face swap in screenshots.*
- [ ] **TASK-105** Destroyers: hammer DONE 2026-10-15 (`test_hammer`:
  box + cylinder, kinematic, 0.6s anticipation → slam, trigger → slam →
  squash + shake verified in render test); battle axe + slap hand remain.
  *Accept: trigger → slam → squash + shake visible in render test.*
- [ ] **TASK-106** Character #1: primitive-built brainrot archetype (own
  name, 20–30% geometry difference logged), bob animation via tweens.
  *Accept: difference log written; preview.png approved by Urbish.*
- [ ] **TASK-107** CameraDirector: wide / dramatic-low / follow presets +
  impulse-scaled shake. *Accept: 10s render test shows all 3 angles.*
- [ ] **TASK-108** AudioSynth: procedural boom/whistle DONE 2026-10-15
  (in `test_hammer`, impact-scaled); mixer buses + one Suno chant WAV
  import + trigger remain.
  *Accept: recorded clip has non-silent, synced audio.*
- [ ] **TASK-109** Recorder: `tools/record.sh` → Movie Maker CLI →
  `to_mp4.sh` → finished MP4 + resolution/audio/wall_avg verification.
  *Accept: one-click preset → verified 1080×1920 MP4.*
- [ ] **TASK-110** Staging UI: design-first mockup (HTML, shown in chat,
  recorded as video) → Godot UI (module browser, preset editor, record
  button). *Accept: Urbish stages a scenario in <2 min (timed).*
- [ ] **GATE-1** jarvish playtest: stage → record → MP4, plus
  module-drop test (new folder → registry picks it up, no core edits).
  *Pass: all green.* His ASUS confirmation (TASK-901) runs async and never
  blocks the gate.

## Phase 1.5 — Variation system (the monetization line)

- [ ] **TASK-151** Preset schema v2: camera path, beats timeline, seed,
  music slot, overlay slots. Migrate existing presets.
- [ ] **TASK-152** VariationEngine: samples ≥4 differing axes per sibling;
  sibling presets saved with seeds. *Accept: 3 siblings from one parent,
  diff report shows ≥4 axes changed each.*
- [ ] **TASK-153** Moon arena variant + 2 obstacle modules (lava pit,
  drain pipe). *Accept: lint green, previews approved.*
- [ ] **GATE-1.5** Render 3 videos from siblings; Urbish confirms they feel
  like different episodes, not one template.

## Phase 2 — Legal & asset compliance (before first upload)

- [ ] **TASK-201** Character audit: every character vs ADR-007 (archetype,
  geometry diff %, own name, no brand marks). Difference logs complete.
- [ ] **TASK-202** Audio audit: Suno files isolated in assets/chants/;
  fallback ladder documented (TikTok free-to-use → own voice → procedural).
- [ ] **TASK-203** Upload checklist: Made-for-Kids setting, title/desc
  template, no trademarked words in metadata.
- [ ] **GATE-2** Urbish signs off the compliance file. No upload before this.

## Phase 3 — Validation

- [ ] **TASK-301** Render 5 differentiated scenes (overnight batch on jarvish).
- [ ] **TASK-302** Urbish edits in CapCut (text overlays, cuts, sound layer).
- [ ] **TASK-303** Publish 15–20 videos across Shorts/Reels/TikTok.
- [ ] **TASK-304** Read retention at 48h/7d.
- [ ] **GATE-3** Any video >10K views → Phase 4. All flat → diagnose (hook?
  format? variation?) before building more. Park is an acceptable outcome.

## Phase 4 — Factory automation (ONLY if GATE-3 passes)

- [ ] **TASK-401** BatchQueue hardening: queue.json → sequential overnight
  renders → ffmpeg → done/ + failure alerts.
- [ ] **TASK-402** CapCut template pack (his edit side) + per-video
  variation checklist.
- [ ] **TASK-403** Operating discipline doc (one-app-at-a-time, <12
  min/video target) + weekly output routine.

## Standing
- [ ] **TASK-000** Docs living: after every task, update TASKS.md,
  MEMORY.md (plans/), and DECISIONS.md if a decision changed.
