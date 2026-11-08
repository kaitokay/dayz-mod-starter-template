# DayZ Mod Starter Template

[Version française](README.fr.md)

A clean DayZ mod base that gets a new project running in a few minutes. The starter mod works as it is: it loads, reads its settings and writes to the log. All that's left to add is your idea.

## Why this template

1. **Everything happens in VS Code.** No P: drive, no Workbench, no pboProject. Ctrl+Shift+B runs the build.
2. **One-click local testing.** A single task builds and signs the mod, copies the `.bikey`, starts the server and the client with BattlEye, then shows the logs live.
3. **Safe JSON settings.** Defaults, MIN and MAX are already in place. A broken file won't crash the server: the mod falls back to its defaults.
4. **Secure by default.** Your private keys are created outside the project and blocked by `.gitignore`. A check runs before each release.
5. **Rename in one command.** `MyMod` becomes your mod's name everywhere, file names included.
6. **With or without AI.** The regular docs cover everything, and `AGENTS.md` gives coding assistants the context they need.
7. **Docs in French and English.** The code is in English, and everything that helps you exists in both languages.

## Quick start

1. Install the requirements below, then open this folder in VS Code.
2. Go to **Terminal > Run Task > 1. Check install**. It finds your folders through Steam and tells you what's missing.
3. Run **2. Rename mod** and enter your mod's name, without spaces.
4. Press **Ctrl+Shift+B**: your keys are created and the mod is built into `build/`.
5. Open Steam, then run **4. Test locally**. The server starts, then the game, which joins it by itself. Allow about 2 minutes. Your mod's lines appear in the terminal.

To stop everything, run **6. Close everything**.

### Day to day

1. Change your scripts.
2. Run **6. Close everything** if the server or the game is still open.
3. Run **4. Test locally**. It rebuilds by itself, so there's no need to press Ctrl+Shift+B first.

Nothing hot-reloads: every change means running the test again.

New to this? [md/FIRST_MOD.md](md/FIRST_MOD.md) walks through everything, all the way to publishing.

## Requirements

- Windows 10 or 11
- [DayZ](https://store.steampowered.com/app/221100/DayZ/)
- DayZ Server and DayZ Tools (in Steam, under Tools in your library)
- [VS Code](https://code.visualstudio.com/)

The project must be in a folder without spaces, for example `C:\Mods\MyMod`.

Folders are detected from Steam's configuration, even across several drives. If detection fails, or to force a path, copy `tools/paths.example.bat` to `tools/paths.bat` and fill in the line you need.

## File structure

```
config.cpp                  Declares the mod and its script layers
mod.cpp                     Name, author and description in the launcher
scripts/
  3_Game/
    MyMod_Version.c         The version, and the only place it's written
    MyMod_Log.c             Logging with the [MyMod] prefix
    MyMod_Settings.c        JSON settings, MIN and MAX limits
  4_World/
    MyMod_Player.c          Your spot for the player, items, zombies
  5_Mission/
    MyMod_MissionServer.c   Server entry point
    MyMod_MissionGameplay.c Client entry point
tools/                      Scripts run by the VS Code tasks
md/                         Step-by-step guide, concept, checklist
AGENTS.md, CLAUDE.md        Context for coding assistants
```

Generated, and ignored by git:

```
build/@MyMod                The built mod
build/profiles               Logs and settings.json from local testing
release/@MyMod              The folder to publish
```

Your keys are in `%USERPROFILE%\DayZ-Mod-Keys\MyMod`. **Back this folder up.** Without the private key, every server running your mod will have to install a new key at your next update.

The tasks, in the order you'll use them:

| Task | What it does |
|---|---|
| 1. Check install | Checks DayZ, DayZ Server, DayZ Tools and the keys |
| 2. Rename mod | Replaces `MyMod` everywhere |
| 3. Build (Ctrl+Shift+B) | Creates a signed `build/@MyMod` |
| 4. Test locally | Build, server, client with BattlEye, logs |
| 5. Live logs | Follows the server log without restarting anything |
| 6. Close everything | Closes the server and the client |
| 7. Prepare release | Creates `release/@MyMod`, then checks it |
| 8. Check before publishing | Blocks on a private key, a personal path or a stray file |

## Publishing to the Workshop

1. Change the version in `scripts/3_Game/MyMod_Version.c`. The build copies it to `mod.cpp` and the log shows it at startup.
2. Run **7. Prepare release**. `release/@MyMod` holds only the signed `addons/`, `keys/` and `mod.cpp`, and it gets checked at the end. If the check blocks, fix what it reports and run it again.
3. Open **DayZ Tools** from Steam, then **Publisher**.
4. Choose `release/@MyMod` as the mod folder, add a title, a description and a preview image, then publish.
5. On your Workshop page, remind admins to copy the contents of `keys/` into their server's `keys/` folder.

## Common errors

**The server rejects me, or mentions a signature or a missing `.bikey`.**
The server doesn't have the mod's public key. Task 4 copies it for you. On another server, copy the mod's `keys/MyMod.bikey` into the server's `keys/` folder. If you recreated your keys, run a build and then task 4 to replace the old one.

**BattlEye blocks the launch, or "BattlEye Service" reports an error.**
Make sure Steam is open and DayZ starts normally from Steam. If not, verify DayZ's files in Steam (Properties > Installed Files), and check whether your antivirus is blocking `DayZ_BE.exe` or `BEService_x64.exe`. Don't disable BattlEye: your test would no longer match what your players get.

**"The project path contains a space".**
Local testing refuses these paths because `-mod=` handles them badly. Move the project, for example to `C:\Mods\MyMod`, then reopen the folder in VS Code.

**"DayZ or the server is still open" during a build.**
The game locks the `.pbo`, so it can't be replaced. Run **6. Close everything** and try again.

**`Can't compile "..." script module` in the logs.**
A script error, with the file and line right next to it. Often a class is being used in a layer that's too low: `3_Game` doesn't know about `PlayerBase`, for example.

**My changes in `settings.json` aren't applied.**
The local test file is `build/profiles/server/MyMod/settings.json`, and it's read when the server starts. If a value gets rejected, the log says why.

## Coding with AI

> New to this and coding with AI? Use AI to learn.

Ask it to explain what it writes, and read the code before testing it. `AGENTS.md` already gives it the project structure, the conventions, the DayZ pitfalls and the safety rules: don't touch the keys, don't disable BattlEye, don't start the server without your say-so.

## License

[MIT](LICENSE). Use it, change it and republish it freely.
