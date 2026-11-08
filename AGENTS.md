# Instructions for coding assistants

This repository is a DayZ mod base. The person using it may be a beginner: explain what you do and why, so they learn along the way.

## Structure

| Item | Role |
|---|---|
| `config.cpp` | Declares the mod and its script layers. The mod name is read from here (`dir`). |
| `mod.cpp` | Name, author and description in the launcher. The version is added at build time. |
| `scripts/3_Game/` | Version, log, JSON settings. |
| `scripts/4_World/` | Player, items, zombies. |
| `scripts/5_Mission/` | Entry points: `MissionServer` and `MissionGameplay`. |
| `tools/` | PowerShell scripts run by the VS Code tasks. |
| `tools/include.txt` | What goes into the `.pbo`. Any new mod folder must be listed here. |
| `build/`, `release/` | Generated, ignored by git. Don't edit them by hand. |

## The layers

A layer sees the layers with a lower number, never the other way round.

- `3_Game` doesn't know about `PlayerBase` or the missions.
- `4_World` knows `3_Game`, but not the missions.
- `5_Mission` sees everything.

A class in the wrong layer stops the scripts compiling, and the server won't start.

## Conventions

- `MyMod_` prefix on every class and file. In a modded vanilla class, prefix new methods and variables too, to avoid clashes between mods.
- Comments, log messages, JSON settings and script messages in English.
- Documentation in French and English. When you change a doc, change both versions: `README.md` and `README.fr.md`, `md/PREMIER_MOD.md` and `md/FIRST_MOD.md`, `md/CONCEPT.md` and `md/CONCEPT.fr.md`, `md/CHECKLIST.md` and `md/CHECKLIST.fr.md`.
- Short comments, only when the code isn't enough.
- Logging: `MyMod_Log.Info`, `Warn` or `Err`, never `Print` directly.
- Version: only in `scripts/3_Game/MyMod_Version.c`.
- Each setting has a default, a MIN and a MAX in `MyMod_SettingsLimits`, goes through `CheckInt` (or an equivalent) and appears in the log when loaded.
- Keep `.ps1` files ASCII, or save them as UTF-8 with BOM: otherwise PowerShell 5.1 garbles accents.

## Safety: no exceptions

- Never touch the keys: don't create, copy, read or move a `.biprivatekey`. They stay outside the project.
- Never disable BattlEye, anywhere (`serverDZ.cfg`, launch arguments, scripts).
- Never start the server or the client without the person's explicit agreement.
- Don't commit or push unless asked.
- Don't write personal paths in any project file. Anything specific to one PC goes in `tools/paths.bat`, which git ignores.

## Before using a function

Check that it exists in the vanilla scripts before using it. Don't invent APIs: Enforce Script looks like other languages, but many functions you'd expect don't exist.

The vanilla scripts are in `P:\scripts` if the P: drive is mounted, otherwise in `dta\scripts.pbo` in the DayZ folder. If you can't check, say so instead of guessing.

## Classic DayZ pitfalls

- `override` without `super.` breaks vanilla behaviour, and sometimes other mods.
- A class in the wrong layer gives: `Can't compile "World" script module`.
- Enforce Script has no ternary `a ? b : c`.
- Always test for `null` before using `identity`, a player or an object. A player can disconnect at any moment.
- Client and server code share the same files: use `GetGame().IsServer()` and `GetGame().IsClient()` to tell them apart.
- Anything in `OnUpdate` runs every frame. Prefer a spaced-out `CallLater`.
- The settings folder is in the server's profile: `$profile:MyMod/settings.json`.
- After changing `config.cpp` or the scripts, build again and restart the server: nothing hot-reloads.

## Checking your work

The task `3. Build` (or `tools/build.ps1`) is safe to run. It doesn't prove the scripts compile: only starting the server shows that. When you're done, give the list of what needs testing in game.
