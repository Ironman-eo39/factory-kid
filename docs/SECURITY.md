# SECURITY — Kid-Bait Physics Toy

Internal-only tool, but private-repo hygiene applies.

1. **Repo is PRIVATE, forever.** The toy is never distributed or sold
   (scope lock). Never flip visibility, never publish the repo.
2. **No secrets in the repo.** No API keys, no tokens, no credentials in
   code, docs, presets, or commit messages. (There are no network calls in
   the toy at all — nothing to key.)
3. **Suno audio licensing** is a legal exposure, not a secret: his explicit
   override (ADR-008); files isolated in `assets/chants/` for swap-out.
4. **Backups** (daily jarvish → Muse VM) contain only project files —
   no credentials live in the project, so backups are safe to keep.
5. **No analytics, no telemetry, no network calls** from the toy (RULES #10).
   Nothing phones home; nothing to leak.
