# Liste de vérification

[English version](CHECKLIST.md)

Cette liste te sert à vérifier que le template marche sur ton PC. Si quelque chose bloque, regarde les erreurs fréquentes dans le [README](../README.fr.md).

## Installation

- [ ] **1. Check install** affiche `[OK]` pour DayZ, DayZ Server et DayZ Tools.
- [ ] **2. Rename mod** remplace `MyMod` par le nom de ton mod partout.
- [ ] Tu as mis ton pseudo et ta description dans `mod.cpp`.
- [ ] **Ctrl+Shift+B** crée `build/@MyMod`, et tes clés sont dans `%USERPROFILE%\DayZ-Mod-Keys\MyMod`.
- [ ] Tu as sauvegardé le dossier des clés.

## Test local

- [ ] **4. Test locally** démarre le serveur, puis le jeu, qui rejoint avec BattlEye actif.
- [ ] Le terminal affiche `Server started`, `Settings loaded` et `Player connected`, une seule fois chacun.
- [ ] Le fichier `build/profiles/client/script_*.log` contient `Client started`.
- [ ] **3. Build** refuse de démarrer quand le serveur est ouvert, et **6. Close everything** le débloque.

## Réglages

Modifie `build/profiles/server/MyMod/settings.json`, puis lance **6. Close everything** et **4. Test locally** après chaque changement.

- [ ] `"ExampleValue": 500` donne une ligne `WARNING` et revient à 10.
- [ ] Une accolade supprimée donne une ligne `ERROR`, et le serveur démarre quand même. Remets l'accolade ensuite.

## Publication

- [ ] **7. Prepare release** crée `release/@MyMod` avec seulement `addons/`, `keys/` et `mod.cpp`, et finit par `All clear`.
- [ ] Le Publisher de DayZ Tools accepte `release/@MyMod`.
- [ ] Après `git add .`, **8. Check before publishing** finit toujours par `All clear`.
