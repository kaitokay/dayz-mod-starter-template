# Checklist

[Version française](CHECKLIST.fr.md)

Use this list to check that the template works on your PC. If something fails, see the common errors in the [README](../README.md).

## Setup

- [ ] **1. Check install** shows `[OK]` for DayZ, DayZ Server and DayZ Tools.
- [ ] **2. Rename mod** replaces `MyMod` with your mod's name everywhere.
- [ ] You've set your name and description in `mod.cpp`.
- [ ] **Ctrl+Shift+B** creates `build/@MyMod`, and your keys are in `%USERPROFILE%\DayZ-Mod-Keys\MyMod`.
- [ ] You've backed up the keys folder.

## Local test

- [ ] **4. Test locally** starts the server, then the game, which joins with BattlEye active.
- [ ] The terminal shows `Server started`, `Settings loaded` and `Player connected`, each once.
- [ ] The file `build/profiles/client/script_*.log` contains `Client started`.
- [ ] **3. Build** refuses to run while the server is open, and **6. Close everything** clears it.

## Settings

Edit `build/profiles/server/MyMod/settings.json`, then run **6. Close everything** and **4. Test locally** after each change.

- [ ] `"ExampleValue": 500` gives a `WARNING` line and goes back to 10.
- [ ] Deleting a brace gives an `ERROR` line, and the server still starts. Put the brace back afterwards.

## Publishing

- [ ] **7. Prepare release** creates `release/@MyMod` with only `addons/`, `keys/` and `mod.cpp`, and ends with `All clear`.
- [ ] The DayZ Tools Publisher accepts `release/@MyMod`.
- [ ] After `git add .`, **8. Check before publishing** still ends with `All clear`.
