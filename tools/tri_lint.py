#!/usr/bin/env python3
"""tri_lint.py — hard performance budget enforcement (RULES #8, ADR-006).

Checks every model asset under content/:
  - .glb / .gltf : parse the mesh data, count triangles (must be <= 3000).
  - .tscn        : primitive-built scenes can't be tri-counted statically;
                   flagged for runtime checking in the render smoke test.

Usage:
  tri_lint.py [--content DIR] [--limit N] [--dry-run]
Exit code: 0 = all green, 1 = budget violation.
"""
import argparse
import json
import struct
import sys
from pathlib import Path

DEFAULT_LIMIT = 3000


def count_gltf_tris(path: Path) -> int:
    data = path.read_bytes()
    if path.suffix == ".glb":
        magic, version, length = struct.unpack("<III", data[:12])
        assert magic == 0x46546C67, f"bad glb magic in {path}"
        off = 12
        js = None
        while off < len(data):
            chunk_len, chunk_type = struct.unpack("<II", data[off:off + 8])
            if chunk_type == 0x4E4F534A:  # JSON
                js = json.loads(data[off + 8:off + 8 + chunk_len])
                break
            off += 8 + chunk_len
        if js is None:
            raise ValueError(f"no JSON chunk in {path}")
    else:
        js = json.loads(data.decode("utf-8"))

    accessors = js.get("accessors", [])
    total = 0
    for mesh in js.get("meshes", []):
        for prim in mesh.get("primitives", []):
            mode = prim.get("mode", 4)
            if mode != 4:  # only TRIANGLES counted
                continue
            attrs = prim.get("attributes", {})
            if "indices" in prim:
                total += accessors[prim["indices"]]["count"] // 3
            elif "POSITION" in attrs:
                total += accessors[attrs["POSITION"]]["count"] // 3
    return total


def main() -> int:
    ap = argparse.ArgumentParser(description="Tri-count budget lint for content modules.")
    ap.add_argument("--content", default="content", help="content/ directory")
    ap.add_argument("--limit", type=int, default=DEFAULT_LIMIT, help="max tris per model")
    ap.add_argument("--dry-run", action="store_true", help="list assets that would be checked")
    args = ap.parse_args()

    root = Path(args.content)
    assets = sorted(p for p in root.rglob("*") if p.suffix in (".glb", ".gltf", ".tscn"))
    if args.dry_run:
        print(f"[dry-run] would check {len(assets)} assets under {root}")
        for a in assets:
            print("  ", a)
        return 0

    failures = 0
    runtime_only = 0
    for a in assets:
        if a.suffix == ".tscn":
            runtime_only += 1
            print(f"SKIP (runtime-checked): {a}")
            continue
        try:
            tris = count_gltf_tris(a)
        except Exception as e:  # noqa: BLE001
            print(f"ERROR reading {a}: {e}")
            failures += 1
            continue
        status = "OK " if tris <= args.limit else "FAIL"
        if tris > args.limit:
            failures += 1
        print(f"{status} {tris:6d} tris  {a}")
    print(f"--- {len(assets)} assets, {failures} over budget, {runtime_only} tscn (runtime-checked)")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
