# Claude Handoff — Kid Toy Factory engine-v2

## What this is
Godot 4.6 project that renders kids' Shorts offline (1080×1920, 30fps).
Characters walk down a road, a hammer pistons up/down, hits launch them flying.
`./tools/record.sh --out /tmp/x <preset>` → MP4.

## Branch
`engine-v2` on https://github.com/UrbishCodes/kid-toy-factory

## What's working
- **Procession movement** (`plonko.gd`): characters walk +Z down the road, staggered, loop back. Stay upright.
- **Piston hammer** (`hammer.gd`, `mode: "swing"`): sine wave up/down. Hits when down, characters pass under when up.
- **Launch hit style** (`hit_style: "launch"`): hammer contact → rocket up (14-20 m/s), wild spin, stretch mid-flight, squash on landing.
- **Camera** (`camera_director.gd`): 7 modes (wide, low, follow, closeup, topdown, side, orbit) + timed `cuts` + smooth `path` dolly. Preset-driven.
- **Recording** (`tools/record.sh`): verified 1080×1920 h264+aac.

## Known bugs (deferred, fix these)
1. **Low camera angle** doesn't fill frame — car is small/poorly framed. See BUG comment in `camera_director.gd`.
2. Characters sometimes clip through each other in procession.
3. Hammer timing vs character spacing not tuned — some hits feel random.

## What Urbish wants from you
**Visual quality + physics realism.** His words: "happy with 15fps realistic, don't want 200fps blob."

1. **Character models**: realistic proportions, proper topology, materials that look real (wood grain, etc.). Faces that read at distance.
2. **Physics**: weighty feel — proper mass, friction, bounce. Soft-body-ish squash (not just scale trick). Dust puff on impact.
3. **Scenes**: depth, proper lighting, shadows. Less "flat game engine default."
4. **Exaggeration**: childish, big, cartoonish — wide eyes, bouncy movement, huge reactions. (But built on solid realistic base.)

## Hit styles to build (Urbish guides each)
- ✅ launch (done)
- ⏳ compress+bounce: character squashes flat, springs back, hammer bounces off wildly
- ⏳ deform: character stays dented for seconds before popping back

## Key files
- `game/content/characters/plonko/plonko.gd` — character logic
- `game/content/destroyers/test_hammer/hammer.gd` — hammer logic
- `game/scripts/core/camera_director.gd` — camera
- `game/scripts/core/scenario_runner.gd` — preset runner
- `game/presets/procession_test.json` — main test scene
- `game/presets/cam_showcase.json` — camera demo

## Urbish's rules
- Test on jarvish (his Linux laptop), not just compile
- One small task at a time, show renders for review
- English only, terse updates
- Copyright for characters is his call (ADR-007b) — don't re-litigate
