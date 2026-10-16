# Claude Handoff — Kid Toy Factory

## The situation (read this first)
Urbish is NOT happy with what Muse modelled. The characters, scenes, movements — all of it looks fake, simple, and bland. He wants you to model EVERYTHING from scratch.

**What Muse built (keep this):**
- Camera angle code (`camera_director.gd`) — 7 angles, cuts, dolly paths
- Basic recording structure (`tools/record.sh` → 1080×1920 MP4)
- That's it. The engine skeleton. Everything visual is yours to redo.

**What you need to build (everything else):**
- Every character — model, texture, proportions, face
- Every movement — walk cycles, idle, reactions, hit responses
- Every expression — eyes, mouth, emotions that read at a distance
- Every obstacle — design and model
- Every surrounding/scenery — background, depth, atmosphere
- Every texture — materials that look real, not flat game-engine default

## Character copyright (Urbish's call)
Urbish takes full responsibility for copyright risk — "it's on him."
Model characters **90% similar** to the references he provides. Don't water them down, don't "original-ify" them. He wants them close.

## Reference files (Urbish will provide)
1. **Character/scene references** — he will generate and share these. Follow them closely.
2. **Cocomelon research** — he will share his research on their technique. You MUST understand and implement it.

## The Cocomelon technique (critical)
Urbish explained how Cocomelon hooked every kid:
- **Colors and flashy visuals** — saturated, high-contrast, impossible to ignore
- **Sound synced to action** — every movement has a matching sound
- **Scene/element change every ~3 seconds** — never let the screen go static
- **They did real research**: put kids in front of videos, recorded the exact moment a kid looked away, then reworked those portions until kids couldn't look away
- The result: so much color, movement, character emotion, and sound variation that kids literally cannot look away

**You need to implement this in our game:**
- Every 3 seconds SOMETHING changes — camera angle, character action, color pop, sound cue
- Characters need big readable emotions — happy, scared, surprised, dizzy
- Colors must be vivid and saturated, not muted
- Sound design synced to every hit, bounce, and movement
- If a scene feels static for even a moment, it's wrong

## Technical details
- **Branch:** `engine-v2` on https://github.com/UrbishCodes/kid-toy-factory
- **Engine:** Godot 4.6, renders offline via `--write-movie` (1080×1920, 30fps)
- **Test:** `./tools/record.sh --out /tmp/x <preset_name>` → MP4
- **Presets:** `game/presets/*.json` — scenario definitions
- **Urbish's performance stance:** "happy with 15fps realistic, don't want 200fps blob" — quality over speed

## Key files (structure to keep, visuals to replace)
- `game/content/characters/plonko/plonko.gd` — character logic (movement code works, model doesn't)
- `game/content/destroyers/test_hammer/hammer.gd` — hammer piston logic works
- `game/scripts/core/camera_director.gd` — camera system works
- `game/scripts/core/scenario_runner.gd` — preset runner works
- `game/presets/procession_test.json` — main test: characters walk road, hammer smashes

## Known bugs
1. Low camera angle doesn't fill frame (marked in code, deferred)
2. Characters clip through each other in procession

## Urbish's working rules
- One small task at a time, show renders for review
- Test actual renders, not just code
- English only, terse updates
- He reviews every visual change — nothing merges without his eye on it
