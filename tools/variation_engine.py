#!/usr/bin/env python3
"""VariationEngine — generates sibling presets from a parent preset.

Each sibling differs on >=4 axes (TASK-152 acceptance). Saves siblings
with seeds + prints a diff report.

Usage:
    python3 tools/variation_engine.py --parent game/presets/plonko_test.json \
        --count 3 --out game/presets/

Axes that can vary:
    roster_id, roster_count, destroyer_id, destroyer_pos, camera_mode,
    camera_path, beat_times, music_chant, overlay_text, duration, arena_id
"""
import argparse, copy, json, random, sys
from pathlib import Path

# Candidate values per axis (only ones that exist in the repo)
ROSTER_IDS = ["plonko", "test_ball", "moon_ball", "sedan", "suv", "hatchback", "race", "taxi"]
DESTROYER_IDS = ["test_hammer", "test_axe", "test_hand"]
CAMERA_MODES = ["wide", "low", "follow"]
CHANTS = ["res://audio/chant_placeholder.wav"]
def _titles(roster_id: str, destroyer_id: str) -> tuple[str, str]:
    cast = {"plonko": "PLONKO", "test_ball": "BOUNCY BALLS",
            "moon_ball": "MOON BALLS"}.get(roster_id, roster_id.upper().replace("_", " "))
    if roster_id in ("sedan", "suv", "hatchback", "race", "taxi"):
        cast = "CANDY CARS"
    weapon, impact = {"test_hammer": ("HAMMER", "SMASH!"),
                      "test_axe": ("AXE", "CRASH!"),
                      "test_hand": ("HAND", "SLAP!")}.get(destroyer_id, ("SMASHER", "BOOM!"))
    return f"{cast} vs {weapon}", impact

def load(p): return json.load(open(p))

def vary(parent: dict, rng: random.Random, idx: int) -> tuple[dict, list[str]]:
    s = copy.deepcopy(parent)
    changed = []
    pid = parent["id"]
    s["id"] = f"{pid}_v{idx+1}"
    s["display_name"] = f"{parent.get('display_name', pid)} (var {idx+1})"
    s["version"] = 2
    s["seed"] = rng.randint(0, 99999)

    # pick >=4 axes to vary
    axes = ["roster", "destroyer", "camera", "beats", "overlays", "duration"]
    rng.shuffle(axes)
    for ax in axes[:4]:
        if ax == "roster" and s.get("rosters"):
            r = s["rosters"][0]
            old_id, old_n = r["id"], r.get("count", 6)
            r["id"] = rng.choice([x for x in ROSTER_IDS if x != old_id])
            r["count"] = rng.choice([c for c in (4, 6, 8, 10) if c != old_n])
            changed.append(f"roster: {old_id}x{old_n} -> {r['id']}x{r['count']}")
        elif ax == "destroyer" and s.get("destroyer"):
            d = s["destroyer"]
            old = d["id"]
            d["id"] = rng.choice([x for x in DESTROYER_IDS if x != old])
            # nudge position
            pos = d.get("params", {}).get("position", [0, 7.0, 2.0])
            d.setdefault("params", {})["position"] = [
                round(pos[0] + rng.uniform(-2, 2), 1),
                round(pos[1] + rng.uniform(-1, 1), 1),
                round(pos[2] + rng.uniform(-1, 1), 1),
            ]
            changed.append(f"destroyer: {old} -> {d['id']} @ {d['params']['position']}")
        elif ax == "camera":
            cam = s.setdefault("camera", {})
            old_mode = cam.get("mode", "wide")
            cam["mode"] = rng.choice([m for m in CAMERA_MODES if m != old_mode])
            # drop path or add a simple one so siblings feel different
            if "path" in cam and rng.random() < 0.5:
                del cam["path"]
                changed.append(f"camera: {old_mode}+path -> {cam['mode']} (no path)")
            else:
                w = rng.uniform(-5, 5)
                cam["path"] = [
                    {"t": 0.0, "pos": [0, 8.5, 14.0], "look": [0, 1.0, 0]},
                    {"t": s["duration"] / 2, "pos": [round(w,1), 6.0, 11.0], "look": [0, 1.0, 0]},
                    {"t": s["duration"], "pos": [0, 8.5, 14.0], "look": [0, 1.0, 0]},
                ]
                changed.append(f"camera: {old_mode} -> {cam['mode']}+path")
        elif ax == "beats" and s.get("beats"):
            for b in s["beats"]:
                old_t = b["t"]
                b["t"] = round(max(0.5, old_t + rng.uniform(-1.5, 1.5)), 1)
            # maybe add an extra beat
            if rng.random() < 0.5 and s.get("destroyer"):
                s["beats"].append({
                    "t": round(s["duration"] * rng.uniform(0.5, 0.8), 1),
                    "action": "trigger", "target": "destroyer"})
                changed.append(f"beats: retimed + extra beat ({len(s['beats'])} total)")
            else:
                changed.append(f"beats: retimed ({len(s['beats'])} beats)")
        elif ax == "overlays":
            s["_vary_overlays"] = True  # deferred: needs final roster/destroyer
            changed.append("overlays: (text set after all axes)")
        elif ax == "duration":
            old_d = s["duration"]
            s["duration"] = round(rng.choice([8.0, 10.0, 12.0, 15.0]), 1)
            if old_d == s["duration"]:
                s["duration"] = 12.0 if old_d != 12.0 else 8.0
            changed.append(f"duration: {old_d}s -> {s['duration']}s")
    if s.pop("_vary_overlays", False):
        rid = s["rosters"][0]["id"] if s.get("rosters") else "plonko"
        did = s.get("destroyer", {}).get("id", "test_hammer")
        title, impact = _titles(rid, did)
        s["overlays"] = [
            {"t": 0.5, "duration": 2.5, "text": title, "size": 84, "y": 300},
            {"t": round(s["duration"] * 0.6, 1), "duration": 2.0,
             "text": impact, "size": 120, "y": 800},
        ]
        # fix the placeholder message
        changed = [c if c != "overlays: (text set after all axes)"
                   else f"overlays: -> '{title}' / '{impact}'" for c in changed]
    return s, changed

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--parent", required=True)
    ap.add_argument("--count", type=int, default=3)
    ap.add_argument("--out", required=True)
    ap.add_argument("--seed", type=int, default=None)
    a = ap.parse_args()
    parent = load(a.parent)
    rng = random.Random(a.seed)
    outdir = Path(a.out)
    outdir.mkdir(parents=True, exist_ok=True)
    print(f"parent: {parent['id']}  siblings: {a.count}")
    for i in range(a.count):
        sib, changed = vary(parent, rng, i)
        assert len(changed) >= 4, f"sibling {i}: only {len(changed)} axes"
        fp = outdir / f"{sib['id']}.json"
        json.dump(sib, open(fp, "w"), indent=1)
        print(f"\n[{sib['id']}] seed={sib['seed']} ({len(changed)} axes):")
        for c in changed:
            print(f"  - {c}")
        print(f"  saved -> {fp}")
    print("\nOK: all siblings have >=4 differing axes")

if __name__ == "__main__":
    main()
