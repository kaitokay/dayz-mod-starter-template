# Le concept

[English version](CONCEPT.md)

Une base de mod DayZ propre et prête à l'emploi, pour démarrer un projet en quelques minutes, avec ou sans IA. Tout marche directement : on clone, on renomme, on build, on teste.

## Ce que tu obtiens

1. Tout depuis VS Code : pas de disque P:, pas de Workbench, pas de pboProject.
2. Test local en un clic, avec BattlEye et les logs en direct.
3. Réglages JSON sécurisés : MIN, MAX, valeurs par défaut, fichier cassé sans crash.
4. Sécurité par défaut : clés hors du projet, `.gitignore`, vérification avant publication.
5. Renommage du mod en une commande.
6. Prêt pour l'IA et sans IA.
7. Documentation en français et en anglais.

## Les bonnes habitudes à garder

- **Reste simple.** Si un fichier ou une option ne sert pas ton mod, ne le garde pas.
- **Écris la version à un seul endroit** : `MyMod_Version.c`.
- **Ne désactive jamais BattlEye**, et garde tes clés et tes chemins personnels hors du projet.
- **Fie-toi au code de DayZ.** Vérifie chaque fonction dans les scripts vanilla : `P:\scripts` si tu as le disque P:, sinon `dta\scripts.pbo` dans le dossier de DayZ.
- **Écris le code en anglais** : commentaires, logs, réglages JSON et messages des scripts. Garde peu de commentaires, et courts.
- **Garde la documentation dans les deux langues** : quand tu modifies une version, modifie l'autre.

## Pour la suite

- [README](../README.fr.md) : démarrage rapide, tâches et erreurs fréquentes.
- [Ton premier mod](PREMIER_MOD.md) : tout le parcours, étape par étape.
- [Liste de vérification](CHECKLIST.fr.md) : pour vérifier que tout marche sur ton PC.
