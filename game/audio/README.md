# game/audio/

Drop a Suno-exported chant WAV here (e.g. `chant.wav`), then reference it
in a preset:

    "music": {"chant": "res://audio/chant.wav", "volume_db": -10.0}

`chant_placeholder.wav` is a procedural stand-in (rhythmic chant-like pulses
generated offline). Replace the path with the real Suno export whenever
ready — no code changes needed.
