# Product Requirements Document — Kid-Bait Physics Toy (internal content factory)

**Version:** 2.0 (2026-10-15) — rewritten after Gemini/Claude/Kimi reviews + Urbish's overrides.
Supersedes all Three.js-era plan docs in this folder.

## Product
A 3D low-poly physics toy that runs on Urbish's machines, built ONLY as an
internal video factory. He stages "cars vs giant object" scenarios, records
them offline, and posts the clips as kids' Shorts/Reels/TikToks. The clips are
the business; the toy is the factory.

## Problem
Urbish's friend earns decently (~$8–15K lifetime est., ~153.6M views) from a
BeamNG.drive kids Shorts channel ("Moon Cars vs giant objects"). Urbish cannot
copy it directly: BeamNG hangs on his laptop, and the AI-modding wave is a GPU
arms race he can't win. The niche was never about graphics — it's physics
comedy for kids. He needs his own factory that produces unique, ownable
footage with zero marginal cost per video.

## Target Users
Exactly one: Urbish, the producer. The audience (kids watching Shorts) never
touches the software. No accounts, no onboarding, no distribution, no support.

## Goal
Validate the channel: publish 15–20 differentiated videos; if ANY video passes
10K views, scale production. Long-term: reach YPP (1K subs + 10M Shorts views
in 90 days) with a variation-safe, monetizable series.

## Core Features
1. **Scenario staging** — pick arena + cars + destroyer + character, place
   them, hit record. Internal staging UI (functional, minimal).
2. **Offline rendering** — one click produces a finished 1080×1920 @30fps
   clip with in-engine audio. No OBS, no real-time capture in the prod path.
3. **Modular content packs** — characters, vehicles, destroyers, obstacles,
   arenas are drop-in modules (folder + manifest). New content = new folder,
   zero core-code changes. This is the project's load-bearing requirement.
4. **Variation system** — parameterized scenario presets + story beats so no
   two videos are templated copies (YouTube July-2026 inauthentic-content
   rules are the monetization line).
5. **Batch queue** — scene list → sequential overnight renders →
   scripted ffmpeg → H.264 MP4s ready for CapCut.
6. **Procedural + licensed audio** — in-engine impact sounds; Suno chants
   (his explicit override); TikTok free-to-use sounds as fallback.

## MVP
- Godot 4.6 project, Jolt physics, fixed 1/60 step, 30fps recorded output.
- 5 Kenney Car Kit (CC0) cars incl. moon-ball car (sphere collider), candy
  recolors + cartoon face decals.
- 3 primitive-built destroyers: giant hammer, axe, slap hand (CCD enabled).
- 1 original brainrot-archetype mascot built from primitives (own name,
  20–30% geometry difference from any known character, no brand marks).
- 1 arena + staging UI (module browser, preset params, record button).
- Movie Maker pipeline: `--write-movie` → AVI/MJPEG → ffmpeg → H.264 MP4.
- Squash-on-impact tween + procedural impact sounds.
- Per-video variation: 3+ varied presets working end to end.

## Out of Scope (v1)
- Soft-body physics (the BeamNG cost we deliberately skip).
- Real-time OBS capture in the production path (preview only, never prod).
- Direct upload automation to TikTok/YouTube/Instagram.
- Analytics feedback loop ("publish and see" is enough for validation).
- CapCut template automation (Phase 4, only if validation passes).
- Public distribution of the toy (SCOPE LOCKED: internal only, forever).
- AI image-to-3D modeling (GPU + legal reasons — see DECISIONS.md).

## Success Criteria
A producer (Urbish) should be able to:
1. Open the staging UI, pick a scenario preset, and start an offline render
   in under 2 minutes (on jarvish).
2. Get a finished 1080×1920 @30fps H.264 clip with non-silent audio,
   with zero dropped frames by construction (rendered on jarvish).
3. Add a brand-new character/obstacle/arena by dropping in a module folder
   — no core code edits, verified by a registry self-test.
4. Produce 3 videos that look and feel like different episodes, not the
   same template.
5. Render a finished video end-to-end in <12 minutes on jarvish (ASUS will
   be faster).

## Hard Gates
- **Phase 0 gate:** capture spike runs on **jarvish** → one clean 60s
  1080×1920 @30fps clip with audio + reported `wall_avg`. No gate pass =
  no game code (fix capture first). The ASUS is NOT a gate — see below.
- **Machine strategy (his correction, 2026-10-15):** jarvish does build +
  test + rendering, ALL of it. jarvish (i5-7300U, HD 620) is the weaker
  machine — if it runs there, it of course runs on the ASUS. The ASUS gets
  a non-blocking confirmation test whenever he has time; development never
  stops waiting for him.
- **Phase 3 gate:** 15–20 videos published, 48h/7d retention checked. Any one
  video >10K views → scale to Phase 4. Otherwise: diagnose or park.

## Constraints
- $0 budget. No paid tools, services, or subscriptions.
- Build + test + render machine: Linux laptop `jarvish` (i5-7300U,
  16GB RAM, Intel HD 620, 158GB free) — holds ALL build files
  (`~/kid-toy-factory/`); daily backup to Muse VM. The weaker machine is
  the reference: if it runs on jarvish, it runs on the ASUS.
- ASUS ZenBook Flip 13 (i5-1135G7, Iris Xe, 8GB, 1080p landscape, Win 11):
  async confirmation only, whenever he has time — never a development gate.
- Perf budget (hard): ≤3k tris/model, ≤100k tris/scene, ≤60 dynamic rigid
  bodies, Lambert/flat materials, 1 dir + 1 hemi light, no shadow maps
  (blob shadows), no post-processing.
- Made-for-Kids classification expected → lower RPM; plan accordingly.
- One-heavy-job-at-a-time discipline on jarvish (never render while
  building/testing). Overnight batch renders OK.
- YouTube 2026 inauthentic-content rules: templated series risk
  demonetization — variation system is mandatory, not polish.

## Risks
| Risk | Mitigation |
|---|---|
| Godot Movie Maker fails the ASUS gate | Three.js+Rapier+CCapture fallback (spike both) |
| Non-deterministic Jolt physics | Record multiple takes, pick the best (feature, not bug) |
| Brainrot IP litigation spillover | Archetype + 20–30% geometry change + own names, no brand marks |
| Suno free-tier ToS on monetized channel | His explicit override; fallback to TikTok free-to-use / own voice |
| Thermal throttling on ASUS | Offline rendering — throttling costs time, never ruins a take |
| 1080p landscape panel | Never window-capture; vertical comes from offline render only |
