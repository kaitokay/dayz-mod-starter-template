# The concept

[Version française](CONCEPT.fr.md)

A clean, ready-to-use DayZ mod base that gets a project started in a few minutes, with or without AI. Everything works straight away: clone, rename, build, test.

## What you get

1. Everything from VS Code: no P: drive, no Workbench, no pboProject.
2. One-click local testing, with BattlEye and live logs.
3. Safe JSON settings: MIN, MAX, defaults, no crash on a broken file.
4. Secure by default: keys outside the project, `.gitignore`, a check before publishing.
5. Rename the mod in one command.
6. Ready with or without AI.
7. Documentation in French and English.

## Good habits to keep

- **Keep it simple.** If a file or an option doesn't serve your mod, leave it out.
- **Write the version in one place only**: `MyMod_Version.c`.
- **Never disable BattlEye**, and keep your keys and personal paths out of the project.
- **Trust DayZ's code.** Check each function in the vanilla scripts: `P:\scripts` if you have the P: drive, otherwise `dta\scripts.pbo` in the DayZ folder.
- **Write the code in English**: comments, logs, JSON settings and script messages. Keep comments few and short.
- **Keep the documentation in both languages**: when you change one version, change the other.

## Where to go next

- [README](../README.md): quick start, tasks and common errors.
- [Your first mod](FIRST_MOD.md): the whole path, step by step.
- [Checklist](CHECKLIST.md): check that everything works on your PC.
