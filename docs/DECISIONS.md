# DECISIONS — Kid-Bait Physics Toy

Permanent decisions with reasoning. Each entry records WHAT we chose, WHY,
what we rejected, and what follows from it — so no future session (or AI)
randomly re-litigates them. Dated; supersede only by explicit Urbish override.

---

## ADR-001 — Engine: Godot 4.6 first (2026-10-15)
- **Decision:** Build the toy in Godot 4.6 (GDScript, Jolt physics,
  Compatibility renderer). Three.js + Rapier + CCapture is the documented
  fallback if Godot fails the Phase 0 gate.
- **Reason:** The decisive factor is capture architecture, not language
  preference. Offline rendering (Movie Maker `--write-movie --fixed-fps 30`)
  eliminates the ASUS's core risks (8GB shared memory, V8 GC spikes, thermal
  throttling, OBS overhead) instead of managing them. Claude's spike already
  rendered 1080×1920 @30fps with audio in a Linux sandbox; Godot has no
  CORS/importmap/WASM packaging pain, a visual scene editor for staging, and
  Jolt is the 4.6 default 3D engine. Kimi's adversarial review confirmed:
  Claude's plan wins architecturally.
- **Rejected:** Three.js + Rapier + OBS real-time (Google's plan) — real-time
  capture bakes every GC/thermal stutter permanently into the video, and
  1080×1920 window capture is physically impossible on the 1080p landscape
  panel (the fatal flaw Google missed).
- **Consequences:** GDScript learning cost (small — AI writes it fine);
  engine switch now is cheap because no production code exists yet.

## ADR-002 — Offline rendering is the production path; OBS is preview-only (2026-10-15)
- **Decision:** Every published video comes from Movie Maker offline renders.
  Real-time OBS capture may be used for quick staging previews only.
- **Reason:** Fixed-step rendering makes dropped frames structurally
  impossible — every frame is rendered and written regardless of wall-clock
  time. Thermal throttling then costs "more time," never "a ruined take."
  Overnight batch rendering becomes possible, which is what makes this a
  factory instead of a hobby.
- **Rejected:** "OBS + QuickSync real-time capture" — impossible at 9:16 on
  this screen, and every frame-time spike is burned into the finished video.
- **Consequences:** Need the ffmpeg → H.264 transcode scripted (AVI/MJPEG is
  big, 4GB cap — fine for ≤60s clips); batch queue design is mandatory.

## ADR-003 — jarvish is the build/test/render machine; ASUS is async confirmation (2026-10-15, corrected by Urbish)
- **Decision:** jarvish does EVERYTHING: build, UI-based testing, and all
  production rendering. The ASUS gets tested only when he has time — it is a
  confirmation, never a gate. Development never stops waiting for him.
- **Reason:** His call after reading the review: jarvish (i5-7300U, HD 620)
  is the weaker machine — if the toy builds, tests, and renders there, it of
  course runs on the stronger ASUS (i5-1135G7, Iris Xe). Blocking development
  on his availability would stall the project for no technical reason.
- **Rejected:** ASUS as the render/prod machine with jarvish as build-only
  (the v2.0 draft — wrong; it made every phase wait on his laptop time).
- **Consequences:** GATE-0 runs on jarvish, not the ASUS. BatchQueue targets
  jarvish (Xvfb + opengl3/llvmpipe for headless renders). The ASUS check
  becomes TASK-901: non-blocking, done whenever he has time.

## ADR-004 — Modularity: content = drop-in modules, zero core edits (2026-10-15)
- **Decision:** Characters, vehicles, destroyers, obstacles, arenas are
  modules (folder + `module.json` manifest + root scene implementing the
  content interface). A `ContentRegistry` autoload scans, validates, and
  spawns them. Scenario presets are data files referencing module IDs.
- **Reason:** Urbish's explicit requirement: add anything later "through
  just code or design." Hardcoding content into core scripts is how toy
  projects die at content #5. The registry self-test makes the contract
  enforceable.
- **Rejected:** Hardcoded scene trees / per-video Godot projects (the
  BeamNG-mod approach — fast day 1, unmaintainable by video 20).
- **Consequences:** Slightly more upfront scaffolding; every new module
  needs a manifest + preview.png; registry validation runs in CI and on
  jarvish smoke tests.

## ADR-005 — Rigid bodies only, fixed 1/60 physics (2026-10-15)
- **Decision:** Jolt rigid-body physics exclusively. No soft-body, no cloth,
  no deformation. Fixed 1/60 step, 30fps recorded output, world in meters,
  CCD on fast destroyers.
- **Reason:** Soft-body is exactly what makes BeamNG hang on this laptop;
  rigid tumbling sells the same joke to kids at a fraction of the cost.
  Fixed step decouples simulation from render — required for offline
  rendering determinism-ish behavior.
- **Rejected:** Soft-body / vertex-deformation squash (perf suicide on
  Iris Xe); variable timestep (non-determinism + capture sync pain).
- **Consequences:** "Squash" is a scale tween on impact, not real
  deformation — visually identical for the audience.

## ADR-006 — Perf budget is hard and linted (2026-10-15)
- **Decision:** ≤3k tris/model, ≤100k tris/scene, ≤60 dynamic bodies,
  Lambert-equivalent materials, 1 dir + 1 hemi light, no shadow maps (blob
  shadows), no post-processing. Enforced by `tri_lint.py`, not by hope.
- **Reason:** The 8GB shared-memory machine has no headroom for "we'll
  optimize later." The budget is the design; the lint makes it stick.
- **Rejected:** "Build pretty, optimize when it lags" — on this hardware,
  lag is discovered after hours of wasted renders.
- **Consequences:** Every asset intake runs the tri check; scenes that
  exceed budget fail the smoke test.

## ADR-007 — Characters: archetype + 20–30% geometry change + own names (2026-10-15)
- **Status: SUPERSEDED by ADR-007b below (2026-10-15, his explicit call).**
- **Decision:** Brainrot archetypes (shark-with-sneakers vibe, log-warrior
  vibe) with deliberately changed silhouettes (20–30% geometry difference),
  our own names, no brand marks (no swoosh, no trademarked words).
- **Reason:** Active brainrot litigation (Do Big vs Mementum Lab; TRALALERO
  word-mark filings) makes near-identical silhouettes a legal gamble even
  if "AI-generated." Familiarity is the hook; distinctiveness is the shield.
  This tightens Urbish's earlier near-identical-silhouette call.
- **Rejected:** Near-identical silhouettes (his 2026-10-10 call — superseded
  by litigation evidence); 1:1 copies (never on the table).
- **Consequences:** Character design needs deliberate differentiation
  passes; keep a per-character "difference log" for the compliance file.

## ADR-007b — Characters: ~90% similarity, copyright is his call (2026-10-15)
- **Decision:** Characters are built ~90% visually similar to their brainrot
  reference archetypes. Copyright is handled by Urbish himself — his explicit
  call ("my call if anything breaks thats on me"), same standing as the Suno
  override (ADR-008). The 20–30% differentiation rule (ADR-007) is dropped.
- **Reason:** The near-identical look IS the hook for this niche; he accepts
  the legal risk personally and will handle any copyright issues himself.
- **Rejected:** The cautious 20–30% differentiation (ADR-007 — superseded).
- **Consequences:** Plonko (built 2026-10-15 to the old rule) gets remodeled
  to ~90% reference similarity. Difference logs are retired; keep a short
  per-character "reference note" naming the archetype instead.
- **Two-phase plan (his call, 2026-10-15):** Phase 1 (now) — ~90% similarity
  to get tried/tested/proven video concepts out fast. Phase 2 — after 2–3
  concepts each cross 10K views on YouTube, characters get edited with our
  own twist (differentiation pass at that point, not before).

## ADR-008 — Audio: Suno stays in (his override), with fallbacks (2026-10-15)
- **Decision:** Suno-generated chants INCLUDED — Urbish explicitly takes the
  ToS risk himself ("my call if anything breaks thats on me"). Fallbacks:
  TikTok sounds marked free-to-use; own voice pitch-shifted; procedural
  in-engine impacts always.
- **Reason:** The reviews proved Suno free tier = personal-use-only (ToS
  violation on a monetized channel; Pro $10/mo breaks $0). He heard the
  evidence and overrode it. His call stands; the fallback ladder keeps the
  project alive if he reverses it.
- **Rejected:** "Suno is zero Content-ID risk" (false — free tier has no
  commercial rights); dropping Suno entirely (his explicit no).
- **Consequences:** Keep Suno files isolated in `assets/chants/` for easy
  swap-out; note TikTok free-to-use licenses are platform-scoped (YouTube
  reuse is outside that license).

## ADR-009 — Variation system is the monetization line (2026-10-15)
- **Decision:** Parameterized variation is a Phase 1.5 deliverable, not
  polish. Every published video must differ on ≥4 variation axes (arena,
  obstacles, camera, lighting, roster, destroyer, beats, music, overlays).
- **Reason:** YouTube's July-2026 inauthentic-content rules explicitly
  target templated series ("same characters, same situations, same
  outcomes") with demonetization. A numbered same-format series without
  variation is exactly the pattern.
- **Rejected:** "Ship the template, vary later" — later is after the
  channel is flagged.
- **Consequences:** VariationEngine is core architecture; presets record
  seeds; validation phase checks variation compliance per video.

## ADR-010 — Vertical-first, single output spec (2026-10-15)
- **Decision:** One output: 1080×1920 @30fps H.264 + AAC, ≤60s. No
  landscape variant, no per-platform re-renders in v1.
- **Reason:** Shorts/Reels/TikTok are all vertical; one spec keeps the
  pipeline simple. Vertical comes from offline rendering (viewport
  1080×1920 + stretch), never from window capture.
- **Rejected:** Multi-format outputs (complexity with zero validation
  signal); 720×1280 internal + upscale as primary (only a fallback if the
  spike shows the direct path failing).
- **Consequences:** Phase 0 spike must verify the actual vertical-output
  path on the ASUS (Movie Maker resolution handling).

## ADR-011 — Test on real rendering, all on jarvish; ASUS is non-blocking confirmation (2026-10-15, corrected by Urbish)
- **Decision:** All testing happens on jarvish: scripted input + screenshot
  capture from actual renders, inspected visually by Muse (Xvfb + opengl3);
  GUT unit tests; recorded-clip verification on jarvish. His manual playtest
  on the ASUS is a non-blocking confirmation whenever he has time — phases
  close on jarvish results, never waiting for him.
- **Reason:** His explicit requirements combined: "actual ui based
  interaction, not just lint and command based testing" AND "use jarvish for
  build and testing and rendering all... that way our development doesn't
  stop." If it renders on the weaker machine, it renders on the ASUS.
- **Rejected:** ASUS-gated phases (v2.0 draft — stalled development on his
  availability); lint/typecheck-only QA; "it compiled, ship it."
- **Consequences:** Test harness + render verification are jarvish-native;
  TASK-901 tracks the async ASUS confirmation without blocking anything.

## ADR-012 — Git from the first change, private repo (2026-10-15)
- **Decision:** Git initialized with the docs commit; small commits, each
  with a distinct descriptive message (his standing rule). Repo stays
  private — the toy is internal-only, forever.
- **Reason:** Playbook rule (AI breaks things; git = rollback) + his scope
  lock (never distributed, never sold). Private by default, like his other
  build repos.
- **Consequences:** jarvish repo init now; never flip visibility without
  his explicit order.

## ADR-013 — One heavy job at a time on jarvish; overnight batch OK (2026-10-15, corrected by Urbish)
- **Decision:** jarvish runs one heavy job at a time (render OR build-test,
  never both). Batch renders run overnight; thermal throttling then only
  costs time.
- **Reason:** Offline rendering makes throttling harmless — but only if the
  machine is otherwise idle. Since jarvish is now the render machine (not
  the ASUS), the discipline moves with it.
- **Rejected:** "Render in the background while building" — the fastest way
  to waste a night.
- **Consequences:** BatchQueue script + a written operating-discipline note
  in the repo; <12 min/video end-to-end target (measured on jarvish; ASUS
  will be faster).

## ADR-014 — Made-for-Kids expected; 10K views is the signal gate (2026-10-15)
- **Decision:** Assume Made-for-Kids classification (lower RPM, no
  personalized ads/comments). Validation gate: any one video >10K views →
  scale. YPP bar (1K subs + 10M Shorts views/90d) is the revenue gate, not
  the validation gate.
- **Reason:** Kids' content gets classified; planning for it avoids
  surprise economics. 10K views proves the format hooks; YPP is months away.
- **Consequences:** Phase 3 measures retention at 48h/7d, not revenue.

## ADR-015 — Primitives first, Blender later; no AI image-to-3D (2026-10-15)
- **Decision:** Destroyers/obstacles/characters start as Godot primitives;
  Blender is the long-term modeling pick (Blockbench had a data-loss report
  — keep backups if used). AI image-to-3D skipped entirely.
- **Reason:** TripoSR needs ~6GB VRAM, TRELLIS/Hunyuan need 16GB+ — the
  Iris Xe can't run them; outputs are dense meshes needing retopo anyway;
  and feeding brainrot reference art into them worsens the legal risk.
- **Consequences:** Per-model spec: ≤3k tris, origin at base, meters scale,
  one material, glTF 2.0, flat colors (candy recolors work), faces as
  separate quads.
