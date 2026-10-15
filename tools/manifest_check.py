#!/usr/bin/env python3
"""manifest_check.py — validate content module contracts (ARCHITECTURE.md).

Every module folder under content/<type>/<id>/ must contain module.json:
  { id, type, display_name, version, root_scene, params_schema?, tags? }
Rules:
  - type must match the parent folder name and be a known content type.
  - id must match the folder name.
  - root_scene file must exist inside the module folder.
  - version must look like X.Y[.Z].

Usage:
  manifest_check.py [--content DIR] [--dry-run]
Exit code: 0 = all valid, 1 = any invalid.
"""
import argparse
import json
import re
import sys
from pathlib import Path

KNOWN_TYPES = {"vehicles", "destroyers", "characters", "obstacles", "arenas"}
REQUIRED = {"id", "type", "display_name", "version", "root_scene"}
VERSION_RE = re.compile(r"^\d+\.\d+(\.\d+)?$")


def check_module(mod_dir: Path):
    errors = []
    mf = mod_dir / "module.json"
    if not mf.exists():
        return [f"{mod_dir}: missing module.json"]
    try:
        m = json.loads(mf.read_text())
    except json.JSONDecodeError as e:
        return [f"{mf}: invalid JSON: {e}"]
    missing = REQUIRED - set(m)
    if missing:
        errors.append(f"{mf}: missing keys {sorted(missing)}")
    if m.get("id") != mod_dir.name:
        errors.append(f"{mf}: id '{m.get('id')}' != folder '{mod_dir.name}'")
    parent_type = mod_dir.parent.name
    if m.get("type") != parent_type:
        errors.append(f"{mf}: type '{m.get('type')}' != folder '{parent_type}'")
    if m.get("type") not in KNOWN_TYPES:
        errors.append(f"{mf}: unknown type '{m.get('type')}'")
    if not VERSION_RE.match(str(m.get("version", ""))):
        errors.append(f"{mf}: bad version '{m.get('version')}'")
    rs = m.get("root_scene")
    if rs and not (mod_dir / rs).exists():
        errors.append(f"{mf}: root_scene '{rs}' not found in module")
    return errors


def main() -> int:
    ap = argparse.ArgumentParser(description="Validate content module manifests.")
    ap.add_argument("--content", default="content", help="content/ directory")
    ap.add_argument("--dry-run", action="store_true", help="list modules that would be checked")
    args = ap.parse_args()

    root = Path(args.content)
    modules = sorted(p for p in root.iterdir() if p.is_dir()) if root.exists() else []
    # support content/<type>/<id> nesting
    mods = []
    for t in modules:
        if t.is_dir():
            mods += [p for p in t.iterdir() if p.is_dir()]
    if args.dry_run:
        print(f"[dry-run] would check {len(mods)} modules under {root}")
        for m in mods:
            print("  ", m)
        return 0

    all_errors = []
    for mod in mods:
        errs = check_module(mod)
        if errs:
            all_errors += errs
            print(f"FAIL {mod}")
        else:
            print(f"OK   {mod}")
    for e in all_errors:
        print("  !", e, file=sys.stderr)
    print(f"--- {len(mods)} modules, {len(all_errors)} errors")
    return 1 if all_errors else 0


if __name__ == "__main__":
    sys.exit(main())
