# Prints - 3D Printable Objects (OpenSCAD)

## What This Repo Is
OpenSCAD parametric designs (.scad) producing STL files for Bambu Lab printer (via Bambu Studio).

## Directory Structure
```
prints/
├── boardgames/
│   ├── <game_name>/          # One folder per board game
│   │   └── <token_name>/    # One subfolder per token/piece
│   │       ├── *.scad       # Source file
│   │       └── *.stl        # Generated STLs
│   └── general/              # Game-agnostic pieces (dice, etc.)
├── decorations/              # Seasonal/decorative items
├── frosthaven/               # Frosthaven-specific pieces
└── pc/                       # Computer/desk accessories
```

## Design Process
1. Design in OpenSCAD using parametric variables at the top of the file
2. Use modules for reusable parts, add comments for key measurements
3. Generate STL: `openscad -o output.stl input.scad`
4. For multi-color: generate one STL per color with `-D 'part="name"'`
5. Copy STLs to shared staging: `cp *.stl /Volumes/BACKUP-1/shared_temp/prints/`
6. Commit & push when done (see below)

## Print-Ready Defaults
- Wall thickness >= 1.2mm
- No overhangs > 45° without supports
- Flat bottom for bed adhesion (chamfer or flat cut)
- 0.2mm layer height tolerance

## Multi-Color (Bambu Studio AMS)
- Separate STL per color part (e.g. `_base.stl`, `_snake.stl`)
- Pattern/accent color must be clipped to outer shell only — never cut holes through the body
- In Bambu Studio: Import first STL → right-click → "Add Part" → select second STL → assign filament per sub-part

## Staging for Print
Always copy final STLs to the shared staging folder so they can be accessed from Bambu Studio:
```bash
cp *.stl /Volumes/BACKUP-1/shared_temp/prints/
```

## Git Workflow
- One commit per design/token (not one giant commit for multiple things)
- Use an emoji that represents the designed object in the commit message
- Format: `feat: 🐍 Spirit Island beast token` or `fix: 🥚 Easter egg hole fix`
- Push after committing: `git push origin main`
- Commit messages should be concise, emoji is close-to-representing what was made

## Overnight / Async Messages
Process user messages fully even if they arrive overnight or after a delay. Don't skip or ignore queued work.
