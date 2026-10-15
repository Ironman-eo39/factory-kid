# PRODUCT.md — Staging UI (kid-toy-factory)

## What it is
The internal scenario-staging tool for the kid-bait physics video factory.
Urbish stages a video (not a game level): pick content modules, arrange the
cast, place destroyer beats on a timeline, choose camera cuts and music, then
record a finished 1080×1920 MP4.

## The one job
**Stage a scenario in under 2 minutes, then record.** Every screen serves that
job. Anything that doesn't make staging faster is cut.

## Screens (one window, four regions)
1. **Library (left)** — browse content modules by type (Arenas, Vehicles,
   Characters, Destroyers). Each card: preview thumbnail, name, tri count.
   One click adds the module to the cast.
2. **Stage (center)** — 9:16 phone-frame preview of the scenario: the cast
   list as chips, the arena name, camera mode indicator. A "Preview" still
   renders the current frame.
3. **Timeline (bottom)** — duration ruler with beat markers (destroyer
   triggers), camera-cut markers, and the chant track. Click to add/move
   markers; the playhead scrubs.
4. **Inspector (right)** — the selected item's editable properties: roster
   count/tint/expression, beat time+target, camera cut mode, music select,
   duration. Save preset / Record.

## Non-goals
- Not a game editor, not a level designer — no 3D manipulation gizmos.
- No public-facing polish; keyboard-first speed over onboarding.
- No dual theme; dark only (it's a video tool, used at night).
