# Contributing

This project aims to keep the default build bit-for-bit identical to the original
Pokemon Yellow ROMs while making the disassembly easier to read, navigate, and
modify.

Use this guide for day-to-day development. Use [INSTALL.md](INSTALL.md) for the
full toolchain setup.

## Quick Start

On Windows, the recommended path is the Docker wrapper:

```powershell
.\build.ps1 compare
```

That command builds the pinned Docker image if needed, runs `make compare`, and
checks the SHA1 sums in [roms.sha1](roms.sha1).

Common wrapper commands:

```powershell
.\build.ps1 compare        # build all checked outputs and verify SHA1 sums
.\build.ps1 all            # build the normal and debug ROMs
.\build.ps1 yellow         # build pokeyellow.gbc only
.\build.ps1 yellow_debug   # build pokeyellow_debug.gbc only
.\build.ps1 yellow_vc      # build pokeyellow.patch
.\build.ps1 unnamed        # list remaining auto-named symbols
.\build.ps1 clean          # remove generated build outputs
.\build.ps1 shell          # open a shell in the Docker build environment
```

On Linux, macOS, WSL, or Cygwin with rgbds 1.0.1 installed:

```sh
make compare
make unnamed
make clean
```

If rgbds is installed in a local folder instead of globally, pass its path:

```sh
make RGBDS=rgbds-1.0.1/ compare
```

## VS Code Setup

This repo includes workspace tasks in [.vscode/tasks.json](.vscode/tasks.json).
Use `Terminal > Run Task...` and choose one of the `pokeyellow:` tasks.

The default build task is:

```text
pokeyellow: compare
```

Recommended extensions are listed in
[.vscode/extensions.json](.vscode/extensions.json). They cover EditorConfig,
Docker, Makefile support, and Markdown editing.

Editor defaults are in [.editorconfig](.editorconfig). They keep line endings,
indentation, final newlines, and whitespace consistent with the rest of the
repository.

## Repository Map

| Path | Purpose |
| --- | --- |
| [audio/](audio/) | Music, sound effects, cries, and audio engine data. |
| [constants/](constants/) | Numeric IDs, hardware constants, and shared symbolic values. |
| [data/](data/) | Structured game data: Pokemon, moves, maps, trainers, items, text pointers, and tables. |
| [docs/](docs/) | Project notes and documented bugs or glitches. |
| [engine/](engine/) | Banked game logic grouped by feature area. |
| [gfx/](gfx/) | Source graphics, tilemaps, blocksets, and generated graphics includes. |
| [home/](home/) | Home-bank routines and helpers that are broadly reachable. |
| [macros/](macros/) | RGBDS macros for scripts, data, assertions, far calls, and constants. |
| [maps/](maps/) | Map block data. |
| [ram/](ram/) | WRAM, HRAM, SRAM, and VRAM layouts. |
| [scripts/](scripts/) | Map scripts and event logic. |
| [text/](text/) | Map and event text. |
| [tools/](tools/) | Local C and Python build helpers. |
| [vc/](vc/) | Virtual Console patch data. |
| Root `*.asm` files | Top-level build units included by the Makefile. |

## Common Edit Locations

For text edits, start in [text/](text/) and follow references from the matching
map script in [scripts/](scripts/).

For map behavior, check [scripts/](scripts/), [data/maps/headers/](data/maps/headers/),
[data/maps/objects/](data/maps/objects/), and the corresponding [maps/](maps/)
`.blk` file.

For Pokemon data, check [data/pokemon/](data/pokemon/), then the matching
constants in [constants/](constants/).

For trainer parties and battle setup, check [data/trainers/](data/trainers/),
[engine/battle/](engine/battle/), and related constants.

For graphics, edit the source asset when possible, usually a `.png`, `.tilemap`,
`.blk`, `.bst`, or `.wav` input. Generated `.1bpp`, `.2bpp`, `.pic`, and `.pcm`
files are build outputs.

For RAM names or layout changes, start in [ram/](ram/) and search for all reads
and writes before renaming or resizing anything.

## Matching Builds

The default build must stay matching unless a change is explicitly adding a
separate non-matching build mode.

Before sending a change, run:

```sh
make compare
```

or on Windows:

```powershell
.\build.ps1 compare
```

Do not commit generated build outputs such as `.gbc`, `.gb`, `.patch`, `.sym`,
`.map`, `.o`, `.1bpp`, `.2bpp`, `.pic`, `.pcm`, or tool binaries. They are
ignored by [.gitignore](.gitignore).

If you are documenting or implementing a gameplay bug fix, keep the matching
default behavior intact. Prefer documenting the fix first in
[docs/bugs_and_glitches.md](docs/bugs_and_glitches.md), then guard code changes
behind an explicit build flag if a fixed build mode is needed later.

## Naming Work

Use `make unnamed` or `.\build.ps1 unnamed` to find the remaining auto-named
symbols. Increase the per-file listing with:

```sh
make UNNAMED_LIST=25 unnamed
```

Good names should describe the role of the symbol, not just its address or
current implementation detail. Prefer names that remain useful when code moves.

When renaming:

- Search the full repository before and after the change.
- Keep local labels local when they are only meaningful inside one routine.
- Avoid introducing new `unknown_`, address-suffixed, or one-letter global
  names unless there is no better information yet.
- Run `make compare` after the rename.

## Code Style

Follow nearby code. This repo intentionally keeps assembly formatting close to
the surrounding file so diffs stay reviewable.

General rules:

- Use RGBDS syntax and existing macros instead of inventing local variants.
- Keep comments factual and useful; explain hardware behavior, data formats, or
  non-obvious control flow.
- Leave unrelated labels, spacing, and generated artifacts alone.
- Prefer small, reviewable changes that preserve matching output.

## Verification Checklist

Before opening a pull request or sharing a branch:

```sh
make compare
make unnamed
git status --short
```

On Windows with Docker:

```powershell
.\build.ps1 compare
.\build.ps1 unnamed
git status --short
```

Use the output to confirm:

- SHA1 comparison passes for the expected outputs.
- The unnamed-symbol count did not increase.
- Only intended source, doc, or setup files are changed.
- No generated build outputs are staged.

