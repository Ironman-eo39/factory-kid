# DESIGN.md — Staging UI (kid-toy-factory)

## Brand rules
Toy-factory playful, tool-grade clear. Dark video-tool chrome with the
channel's candy accents. Dense like CapCut, docked like Godot. No gradients
as identity, no emoji icons, no pulsing dots, no lorem ipsum — every string
is real product copy.

## Tokens
```css
--bg: #14161c;          /* app background */
--surface: #1d2029;     /* panels */
--surface-2: #242834;   /* raised cards */
--border: #2e3342;
--text-1: #f2f4f8;
--text-2: #a7adbd;
--text-3: #6b7284;
--accent: #2dd4bf;       /* channel teal — primary actions, selection */
--accent-2: #fb923c;    /* channel orange — record, warnings */
--danger: #f87171;
--success: #4ade80;
--radius-s: 6px; --radius-m: 10px; --radius-l: 16px;
--font: "Inter", system-ui, sans-serif;
--t-fast: 150ms ease-out;   /* feedback */
--t-med: 250ms ease-out;    /* panel transitions */
```

## Type scale
12 (meta/labels) / 13 (body) / 15 (titles) / 20 (panel headers) / 28 (preset
name). Headings Title Case, `text-wrap: balance`. Tabular numerals for
times and counts.

## Components
- **Button:** primary (teal fill, dark text), secondary (surface-2, text-1),
  ghost, destructive. Record is the single primary action per view — big,
  orange, top-right, label "Record".
- **Module card:** 16:9 thumbnail, name (13px), meta line (type · tris).
  Hover: border-accent. Selected: accent ring.
- **Timeline:** ruler with second ticks; beat markers (orange diamonds),
  camera cuts (teal ticks), chant region (teal wash). Playhead: white 2px.
- **Inspector rows:** label (12px, text-3) left, control right. Steppers for
  counts, segmented control for expressions, time fields as `0.0s`.
- **Chips:** cast members as removable chips with count badges.

## Motion
`transform`/`opacity` only. 150ms ease-out on hover/press; 250ms ease-out on
panel/marker moves. Markers follow the pointer while dragging (interruptible).
`prefers-reduced-motion` disables the ambient preview shimmer.

## Never list
- Purple/blue gradients, italic-serif display type, emoji as icons
- Pulsing/placeholder "coming soon" cards — every module card has a real
  thumbnail and real tri count
- Centered vague heroes — this is a tool, every region has a job
- Generic card-grid dashboard look — this is an editor workstation

## Taste notes (persisted user preferences)
- Urbish wants vivid color, never black-and-white-only concepts.
- Terse, dense, phone-first in chat; the tool itself is desktop-dense.
