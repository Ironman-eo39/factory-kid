# DESIGN — Kid-Bait Physics Toy content & staging design

**Version:** 2.0 (2026-10-15).

## Rule #1
Kids decide in 0.5 seconds. Every frame must read instantly: bright thing,
funny face, big motion. No subtlety, no realism, no dark palettes.

## Visual style (locked)
Flat-shaded low-poly cartoon — the Kenney/Quaternius look. One style across
cars, destroyers, characters, arena. Cohesion is what makes it look like "a
game" instead of a clip-art collage.

## Palette
- Day arena: bright blue sky, saturated green/orange ground.
- Moon arena: dark sky + stars, gray cratered ground (the friend's signature look).
- Cars: pure candy colors — red, yellow, purple, lime, cyan. One color per car,
  always high-contrast against the sky.
- Destroyers: wooden brown hammer handle + metallic gray head, comically oversized.

## Cars (Kenney Car Kit, CC0)
- Jeep, bus, sedan, supercar silhouettes — recognizable vehicle types are the cast.
- Candy recolor via material override; big cartoon face decals on both sides
  (white eyes + pupils + mouth; variants: angry / happy / dizzy).
- Big & small scale variants — the size contrast IS the joke.
- Face swap: dizzy eyes for 2s after hard hits, then back to angry.
- Moon-ball car #1: sphere body + 4 wheels, sphere collider.

## Characters (legal line — see DECISIONS.md ADR-007)
- Brainrot ARCHETYPE only (shark with sneakers, log warrior with bat):
  keep the vibe, change the silhouette 20–30%, OUR OWN names, no brand marks
  (no Nike hook, no trademarked words).
- Primitive-built (spheres/capsules/boxes), same flat style as cars.
- Limbs as separate parts, swung with tweens — bobbing mascot, no skeleton.

## Destroyers & obstacles
- Giant hammer (box + cylinder), battle axe (box handle + wedge head),
  slap hand (chunky mitten from boxes + capsules).
- Obstacles: lava pit, drain pipe, ramp — primitive-built, module-contract.
- Comedy timing: anticipation pause (~0.6s) → slam → squash tween on cars →
  impulse-scaled screen shake (~200ms decaying noise).

## Camera grammar (content feature)
- **Wide** — establishing, whole arena.
- **Dramatic low** — near ground looking up at the destroyer.
- **Follow** — tracks the action centroid.
- Per-preset camera path: cut on story beats, never a static single angle.

## Story beats template (every video)
1. **Hook (0–2s):** motion already happening — no cold opens.
2. **Setup:** cast introduced, destroyer looms.
3. **Tension:** anticipation pause, cars wobble.
4. **Release:** slam → squash → shake → sound.
5. **Payoff:** survivor car / slow-mo bounce / funny face close-up → loop bait.

## Variation system (the monetization line)
YouTube's July-2026 inauthentic-content rules target "the same characters
repeatedly in the same situations with the same outcomes." Every published
video must differ from the last on **≥4 of these axes**:
arena layout · obstacle combination · camera path · lighting tint · car
roster/colors · destroyer type · beat timing · music/chant · text overlay
slots. VariationEngine samples this space; the preset records the seed.

## Video output spec
- 1080×1920, 30fps, H.264 + AAC, ≤60s, hook frame inside first 2s.
- Audio: in-engine mix (impacts + chant), non-silent, normalized.
- Post (CapCut, by Urbish): text overlays, fast cuts, trending kid-safe sound
  — the commentary/originality layer the rules want to see.

## Staging UI (internal tool — design-first applies before code)
Functional, not beautiful — but no slop. Layout:
- Left: content browser (modules by type, with preview.png thumbnails).
- Center: 3D viewport (staging view).
- Right: preset params + beats timeline editor.
- Bottom: Record button + batch queue.
Design pass: coded HTML mockup shown in chat → his pick → then Godot UI
code. Mockups recorded as video per his 2026-10-13 requirement.
