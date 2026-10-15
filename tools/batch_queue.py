#!/usr/bin/env python3
"""batch_queue.py — SKELETON (hardened in TASK-401 / Phase 4).

Reads queue.json: { "jobs": [ {"preset": "presets/foo.json"}, ... ] }
Runs them sequentially via tools/record.sh, logging wall-clock time per job.
One heavy job at a time (ADR-013) — this script IS the enforcement.

Usage:
  batch_queue.py [--dry-run] [--help] [queue.json]
Exit code: 0 = all jobs ok, 1 = any job failed.
"""
import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent


def main() -> int:
    ap = argparse.ArgumentParser(description="Sequential overnight render queue (skeleton).")
    ap.add_argument("queue", nargs="?", default="queue.json")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    qpath = Path(args.queue)
    if not qpath.exists():
        print(f"queue file not found: {qpath} (skeleton OK — create one in Phase 4)")
        return 0
    jobs = json.loads(qpath.read_text()).get("jobs", [])
    if args.dry_run:
        print(f"[dry-run] would run {len(jobs)} jobs sequentially:")
        for j in jobs:
            print("  ", j.get("preset"))
        return 0

    print("ERROR: batch_queue.py is a skeleton until TASK-401 (needs record.sh wired).",
          file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
