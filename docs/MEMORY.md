# MEMORY — Kid-bait physics toy project log

## 2026-10-07 — Project born
- Urbish's friend runs BeamNG "Moon Cars vs giant objects" kids channel (@spmrtz):
  60.4K subs, 36 videos, ~153.6M views, top video 39M. Earns decently (~$8–15K lifetime est).
- Urbish's call: don't copy with BeamNG — CODE an original physics toy instead.
- Why: BeamNG hangs on his laptop; AI-modding wave needs GPUs he lacks; the niche is
  physics comedy, not graphics; owning the toy = unique visuals + no clone risk.
- Scope locked: INTERNAL tool only. Laptop-only, never distributed, never sold.
  Content is the business; the toy is the factory.
- Daily nudge cron set (physics-game-daily-nudge, ~9:41 AM NPT).
- Phase-0 plan docs drafted (2D version) — never approved, now superseded.

## 2026-10-10 — Direction pivots (all Urbish's calls)
- NOT one generic brainrot game: a **brainrot-flavored BeamNG-like physics toy in the
  browser**. Car roster (jeep, bus, Lamborghini-style supercar, more) + brainrot-style
  characters and faces.
- Minecraft-simulation clone = SEPARATE parked idea (idea log), not part of this build.
- Characters: near-identical silhouette to known brainrot characters for familiarity,
  subtle detail changes, OUR OWN names. His view: AI-generated = no copyright worry;
  practical line: recognizable + own names avoids trademark/YouTube-enforcement risk.
- Sound: Suno-generated chants/voices (original) + procedural impacts; never ripped audio.
- Planning: Urbish asked if Claude should plan it; recommendation was keep planning
  here (full context, one plan, no drift) with Claude as optional reviewer. He said yes.
- **3D LOCKED** ("just with not too much polygons"): the references are 3D and camera
  angles are part of the watchability. Stack: Three.js + Rapier (WASM rigid-body —
  rigid only, soft-body is the BeamNG cost we skip). Cars from Kenney Car Kit (CC0,
  ~2k tris, verified). Giant objects + brainrot characters primitive-built in code.
  Target 45fps (not 60) on i5-1135G7 / Iris Xe / 8GB, measured WITH OBS capturing.
- Reference pack collected: 15 still images (brainrot roster, gameplay, car side-views)
  + 30 video frames from 6 top Shorts (@spmrtz + @BeamNGoth) → `references/`.
## 2026-10-15 — Consolidated plan of action (external reviews + his overrides)
- Gemini deep-researched + Claude reviewed the plan; Claude built a Godot 4.6
  proof-of-concept spike (kid-toy-spike.zip, "really good" per Urbish); Kimi K3
  validated everything into Master_Architect_Review_and_Blueprint_EN.md.
  Source files: ~/workspace/user/files/.
- HIS CALLS, locked: OFFLINE RENDERING (Godot 4.6 Movie Maker --write-movie
  --fixed-fps 30 first; Three.js+Rapier+CCapture only as fallback). Character line
  tightened to brainrot ARCHETYPE + 20-30% geometry changes + own names — active
  brainrot litigation means near-identical silhouettes are NOT allowed. Suno chants
  stay IN (he takes the ToS risk himself; fallback: TikTok free-to-use sounds).
- Hard laptop facts: 1080p landscape panel → 1080x1920 must come from offline
  render, never window capture; one-app-at-a-time; overnight batch OK.
- Phases: 0) run Claude's record.bat — gate: clean 1080x1920 @30fps + wall_avg;
  1) toy core in winning engine; 1.5) variation system (YouTube 2026
  inauthentic-content rules = the monetization line); 2) legal/asset compliance;
  3) validation (15-20 videos, 10K-view gate); 4) factory automation (overnight
  batch, scripted ffmpeg → H.264).
- PENDING before Phase 0: spike zip, his Claude/Gemini chat docs, extra resources
  he mentioned. Plan rewrite ON HOLD until he locks. Stale docs: plans/
  (Three.js-era) and GOAL.md still describe old direction — DO NOT act on them
  until rewritten.
- This log updated 2026-10-15.

## 2026-10-15 — Plan docs v2.0 written (his order, plan-first)
- Full playbook kit rewritten for the Godot direction: PRD.md, ARCHITECTURE.md,
  DESIGN.md, RULES.md, TASKS.md, DECISIONS.md (15 ADRs with rejected
  alternatives + reasoning), TEST_PLAN.md, SECURITY.md — all in plans/.
- Modularity is the load-bearing design: content = drop-in modules
  (folder + module.json), ContentRegistry autoload, presets as data.
- Testing per his rule: real UI-based interaction on jarvish (scripted input
  + screenshot inspection), not just lint — plus GUT units, plus his manual
  playtest per phase on the ASUS, plus the Phase 0 record.bat gate.
- Machines: ALL build files on jarvish (~/kid-toy-factory/), daily backup to
  Muse VM (his explicit ask); ASUS stays the render/prod machine.
- **GATE-0 PASSED 2026-10-15 (jarvish):** spike rendered 60s 1080×1920
  @30fps, non-silent audio, wall_avg ≈65ms/frame on llvmpipe; MP4
  transcoded. Godot 4.6 Movie Maker confirmed as production path.
- NEXT: Phase 1 — TASK-106 first brainrot archetype (own name, 20–30%
  geometry difference logged), TASK-107 CameraDirector.
  PENDING from him: kid-toy-spike.zip + Claude/Gemini chat docs + extra resources.
- NO game code until he approves these docs.
- **CORRECTION 2026-10-15 (his, after reading the review):** jarvish does
  build + testing + rendering, ALL of it. His logic: jarvish (i5-7300U,
  HD 620) is the weaker machine — if it runs there, it of course runs on
  the ASUS. The ASUS gets an async confirmation test (TASK-901) whenever he
  has time; it is never a gate and development never stops waiting for him.
  GATE-0 moved to jarvish. Docs updated: PRD/ARCHITECTURE/TASKS/TEST_PLAN/
  RULES/DECISIONS (ADR-003, ADR-011, ADR-013 rewritten).
