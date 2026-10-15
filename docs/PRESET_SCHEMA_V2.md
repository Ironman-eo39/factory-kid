# Preset Schema v2

One JSON file = one video. No code changes to make a new video (RULES #6, ADR-004).

## Full example

```json
{
  "id": "plonko_v2test",
  "display_name": "Plonko v2 schema test (12s)",
  "version": 2,
  "seed": 42,
  "duration": 12.0,
  "arena": {"id": "day_arena", "params": {}},
  "destroyer": {"id": "test_hammer", "params": {"position": [0, 7.0, 2.0]}},
  "rosters": [
    {"id": "plonko", "count": 6, "params": {}, "offset": [0, 0.85, 0]}
  ],
  "beats": [
    {"t": 2.0, "action": "trigger", "target": "destroyer"}
  ],
  "camera": {
    "mode": "wide",
    "path": [
      {"t": 0.0, "pos": [0, 8.5, 14.0], "look": [0, 1.0, 0]},
      {"t": 6.0, "pos": [-4, 6.0, 11.0], "look": [0, 1.0, 0]}
    ],
    "cuts": [
      {"t": 3.0, "mode": "low"},
      {"t": 9.0, "mode": "follow", "target": "destroyer"}
    ]
  },
  "music": {"chant": "res://audio/chant_placeholder.wav", "volume_db": -10.0},
  "overlays": [
    {"t": 0.5, "duration": 2.5, "text": "PLONKO vs HAMMER", "size": 84, "y": 300}
  ]
}
```

## Fields

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string | yes | Unique preset id, matches filename |
| `display_name` | string | no | Human label |
| `version` | int | no | 2 = current. v1 presets (no version) still load |
| `seed` | int | no | RNG seed for reproducible layouts/physics jitter |
| `duration` | float | yes | Seconds; runner quits at end |
| `arena` | object | yes | `{"id", "params"}` — spawned via ContentRegistry |
| `destroyer` | object | no | `{"id", "params"}` |
| `rosters` | array | no | `[{"id", "count", "params", "offset"}]` — grid layout |
| `beats` | array | no | Timed actions: `{"t", "action", "target"}` — calls `target.action()` |
| `camera.mode` | string | no | `wide` / `low` / `follow` |
| `camera.path` | array | no | Waypoints `{"t", "pos": [x,y,z], "look": [x,y,z]}` — smooth interpolated dolly |
| `camera.cuts` | array | no | Hard cuts `{"t", "mode", "target"}` |
| `music.chant` | string | no | Audio path played via AudioSynth |
| `music.volume_db` | float | no | Default -10 |
| `overlays` | array | no | Text cards `{"t", "duration", "text", "size", "y"}` — 1080×1920, white w/ black outline, centered |

## Notes

- `path` and `cuts` can combine: path gives smooth motion, cuts snap to a mode.
- When `path` is active it overrides the mode's static position each frame.
- Overlays render on a CanvasLayer (layer 10) above the 3D view.
- `seed` calls Godot's global `seed()` before spawning — same seed, same run.
