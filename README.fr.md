# DayZ Mod Starter Template

[English version](README.md)

Une base de mod DayZ propre, pour démarrer un nouveau projet en quelques minutes. Le mod de départ fonctionne tel quel : il se charge, lit ses réglages et écrit dans le log. Il ne te reste qu'à ajouter ton idée.

## Pourquoi ce template

1. **Tout se passe dans VS Code.** Pas de disque P:, pas de Workbench, pas de pboProject. Ctrl+Shift+B lance le build.
2. **Test local en un clic.** Une seule tâche fait le build, signe le mod, copie la `.bikey`, démarre le serveur et le client avec BattlEye, puis affiche les logs en direct.
3. **Réglages JSON sécurisés.** Valeurs par défaut, MIN et MAX sont déjà en place. Un fichier cassé ne fait pas planter le serveur : le mod repart sur les valeurs par défaut.
4. **Sécurité par défaut.** Tes clés privées sont créées hors du projet et bloquées par `.gitignore`. Une vérification tourne avant chaque publication.
5. **Renommage en une commande.** `MyMod` devient le nom de ton mod partout, noms de fichiers compris.
6. **Avec ou sans IA.** La documentation classique suffit pour tout faire, et `AGENTS.md` donne le contexte aux assistants de code.
7. **Documentation en français et en anglais.** Le code est en anglais, et tout ce qui t'aide existe dans les deux langues.

## Démarrage rapide

1. Installe les prérequis ci-dessous, puis ouvre ce dossier dans VS Code.
2. Menu **Terminal > Exécuter la tâche > 1. Check install**. Elle trouve tes dossiers via Steam et te dit ce qui manque.
3. Lance la tâche **2. Rename mod** et donne le nom de ton mod, sans espace.
4. Fais **Ctrl+Shift+B** : tes clés sont créées et le mod est compilé dans `build/`.
5. Ouvre Steam, puis lance la tâche **4. Test locally**. Le serveur démarre, puis le jeu, qui le rejoint tout seul. Compte environ 2 minutes. Les lignes de ton mod s'affichent dans le terminal.

Pour tout arrêter, lance la tâche **6. Close everything**.

### Au quotidien

1. Modifie tes scripts.
2. Lance **6. Close everything** si le serveur ou le jeu est encore ouvert.
3. Lance **4. Test locally**. Elle refait le build toute seule, donc pas besoin de Ctrl+Shift+B avant.

Rien ne se recharge à chaud : chaque changement demande de relancer le test.

Tu débutes ? [md/PREMIER_MOD.md](md/PREMIER_MOD.md) reprend tout pas à pas, jusqu'à la publication.

## Prérequis

- Windows 10 ou 11
- [DayZ](https://store.steampowered.com/app/221100/DayZ/)
- DayZ Server et DayZ Tools (dans Steam, section Outils de ta bibliothèque)
- [VS Code](https://code.visualstudio.com/)

Le projet doit être dans un dossier sans espace, par exemple `C:\Mods\MyMod`.

Les dossiers sont détectés grâce à la configuration de Steam, même répartis sur plusieurs disques. Si la détection échoue, ou pour forcer un chemin, copie `tools/paths.example.bat` sous le nom `tools/paths.bat` et remplis la ligne voulue.

## Structure des fichiers

```
config.cpp                  Déclaration du mod et de ses couches de scripts
mod.cpp                     Nom, auteur et description dans le launcher
scripts/
  3_Game/
    MyMod_Version.c         La version, à cet endroit seulement
    MyMod_Log.c             Log avec le préfixe [MyMod]
    MyMod_Settings.c        Réglages JSON, limites MIN et MAX
  4_World/
    MyMod_Player.c          Ta place pour le joueur, les objets, les zombies
  5_Mission/
    MyMod_MissionServer.c   Point d'entrée du serveur
    MyMod_MissionGameplay.c Point d'entrée du client
tools/                      Scripts lancés par les tâches VS Code
md/                         Guide pas à pas, concept, vérification
AGENTS.md, CLAUDE.md        Contexte pour les assistants de code
```

Générés, et ignorés par git :

```
build/@MyMod                Le mod compilé
build/profiles               Logs et settings.json du test local
release/@MyMod              Le dossier à publier
```

Tes clés sont dans `%USERPROFILE%\DayZ-Mod-Keys\MyMod`. **Sauvegarde ce dossier.** Sans la clé privée, chaque serveur qui utilise ton mod devra installer une nouvelle clé à ta prochaine mise à jour.

Les tâches, dans leur ordre d'utilisation :

| Tâche | Ce qu'elle fait |
|---|---|
| 1. Check install | Contrôle DayZ, DayZ Server, DayZ Tools et les clés |
| 2. Rename mod | Remplace `MyMod` partout |
| 3. Build (Ctrl+Shift+B) | Crée `build/@MyMod` signé |
| 4. Test locally | Build, serveur, client avec BattlEye, logs |
| 5. Live logs | Suit le log du serveur, sans relancer quoi que ce soit |
| 6. Close everything | Ferme le serveur et le client |
| 7. Prepare release | Crée `release/@MyMod`, puis le contrôle |
| 8. Check before publishing | Bloque sur une clé privée, un chemin perso ou un fichier inutile |

## Publier sur le Workshop

1. Change la version dans `scripts/3_Game/MyMod_Version.c`. Le build la recopie dans `mod.cpp` et le log l'affiche au démarrage.
2. Lance la tâche **7. Prepare release**. Le dossier `release/@MyMod` ne contient que `addons/` signé, `keys/` et `mod.cpp`, et il est contrôlé à la fin. Si le contrôle bloque, corrige ce qu'il indique et recommence.
3. Ouvre **DayZ Tools** depuis Steam, puis **Publisher**.
4. Choisis `release/@MyMod` comme dossier du mod, ajoute un titre, une description et une image d'aperçu, puis publie.
5. Sur ta page Workshop, rappelle aux admins de copier le contenu de `keys/` dans le dossier `keys/` de leur serveur.

## FAQ des erreurs classiques

**Le serveur me refuse, ou parle de signature ou de `.bikey` manquante.**
Le serveur n'a pas la clé publique du mod. La tâche 4 la copie toute seule. Sur un autre serveur, copie `keys/MyMod.bikey` du mod dans le dossier `keys/` du serveur. Si tu as recréé tes clés, relance un build puis la tâche 4 pour remplacer l'ancienne.

**BattlEye bloque le lancement, ou « BattlEye Service » renvoie une erreur.**
Vérifie que Steam est ouvert et que DayZ démarre normalement depuis Steam. Sinon, vérifie les fichiers de DayZ dans Steam (Propriétés > Fichiers installés), et regarde si ton antivirus bloque `DayZ_BE.exe` ou `BEService_x64.exe`. Ne désactive pas BattlEye : ton test ne ressemblerait plus à ce que verront tes joueurs.

**« The project path contains a space ».**
Le test local refuse ces chemins, car `-mod=` les gère mal. Déplace le projet, par exemple dans `C:\Mods\MyMod`, puis rouvre le dossier dans VS Code.

**« DayZ or the server is still open » pendant le build.**
Le jeu verrouille le `.pbo`, qui ne peut donc pas être remplacé. Lance la tâche **6. Close everything** et recommence.

**`Can't compile "..." script module` dans les logs.**
Une erreur de script, avec le fichier et la ligne juste à côté. Souvent, une classe est utilisée dans une couche trop basse : `3_Game` ne connaît pas `PlayerBase`, par exemple.

**Mes changements dans `settings.json` ne sont pas pris en compte.**
Le fichier du test local est `build/profiles/server/MyMod/settings.json`. Il est lu au démarrage du serveur. Si une valeur est refusée, le log dit pourquoi.

## Coder avec une IA

> Tu débutes et tu codes avec l'IA ? Utilise l'IA pour apprendre.

Demande-lui de t'expliquer ce qu'elle écrit, et relis avant de tester. `AGENTS.md` lui donne déjà la structure du projet, les conventions, les pièges de DayZ et les règles de sécurité : ne pas toucher aux clés, ne pas désactiver BattlEye, ne pas lancer le serveur sans ton accord.

## Licence

[MIT](LICENSE). Utilise, modifie et republie librement.
