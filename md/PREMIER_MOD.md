# Ton premier mod, étape par étape

[English version](FIRST_MOD.md)

Compte une heure si tout est à installer. Aucune connaissance de DayZ n'est nécessaire. Ton mod écrira un message dans le log du serveur à intervalle régulier, avec un délai réglable par les admins. C'est modeste, mais tu auras parcouru tout le chemin jusqu'à la publication.

## 1. Installer les outils

Dans Steam, installe DayZ, puis DayZ Server et DayZ Tools (section Outils de ta bibliothèque). Installe aussi [VS Code](https://code.visualstudio.com/).

Lance DayZ une fois depuis Steam pour vérifier qu'il démarre.

## 2. Récupérer le projet

Place ce dossier à un endroit sans espace dans le chemin, par exemple `C:\Mods\MyMod`. Dans VS Code : **Fichier > Ouvrir le dossier**.

## 3. Vérifier l'installation

Menu **Terminal > Exécuter la tâche > 1. Check install**.

Chaque ligne te dit ce qui a été trouvé. Si un dossier n'est pas détecté, le message indique quoi faire. La ligne sur les clés est normale à ce stade : elles seront créées au premier build.

## 4. Donner un nom à ton mod

Lance la tâche **2. Rename mod** et tape un nom sans espace ni accent, par exemple `MonMod`.

Ouvre ensuite `mod.cpp` et mets ton pseudo et ta description. Dans la suite de ce guide, `MyMod` désigne ton mod : le renommage a aussi mis ce fichier à jour.

## 5. Premier build

Appuie sur **Ctrl+Shift+B**.

Au tout premier build, deux clés sont créées dans `%USERPROFILE%\DayZ-Mod-Keys\MyMod` :

- la `.bikey`, publique, part avec ton mod ;
- la `.biprivatekey`, privée, ne doit jamais être partagée.

Copie ce dossier sur une clé USB ou dans un coffre. Sans la clé privée, les serveurs qui utilisent ton mod devront installer une nouvelle clé à ta prochaine mise à jour.

## 6. Premier test

Ouvre Steam, puis lance la tâche **4. Test locally**. Le serveur s'ouvre dans sa propre fenêtre, puis le jeu démarre et le rejoint tout seul. Compte environ 2 minutes, sans rien toucher.

Dans le terminal, tu dois voir :

```
[MyMod] Server started, version 1.0.0
[MyMod] Settings: file created with default values
[MyMod] Settings loaded: Enabled = true
[MyMod] Settings loaded: ExampleValue = 10
[MyMod] Player connected: Survivor
```

Quand tu as fini, lance la tâche **6. Close everything**.

Retiens ce cycle, tu vas le refaire souvent : tu modifies tes scripts, tu lances **6. Close everything**, puis **4. Test locally**. Cette tâche refait le build toute seule. Rien ne se recharge à chaud, donc chaque changement demande de relancer le test.

## 7. Ajouter ton propre réglage

Ouvre `scripts/3_Game/MyMod_Settings.c`.

Ajoute les limites dans `MyMod_SettingsLimits` :

```c
static const int HEARTBEAT_MINUTES_DEFAULT = 5;
static const int HEARTBEAT_MINUTES_MIN     = 1;
static const int HEARTBEAT_MINUTES_MAX     = 60;
```

Ajoute le réglage dans `MyMod_Settings`. Le nom de la variable devient la clé du JSON :

```c
int HeartbeatMinutes = MyMod_SettingsLimits.HEARTBEAT_MINUTES_DEFAULT;
```

Dans `Load()`, sous la ligne `settings.ExampleValue = CheckInt(...)`, ajoute le contrôle :

```c
settings.HeartbeatMinutes = CheckInt("HeartbeatMinutes", settings.HeartbeatMinutes, MyMod_SettingsLimits.HEARTBEAT_MINUTES_MIN, MyMod_SettingsLimits.HEARTBEAT_MINUTES_MAX, MyMod_SettingsLimits.HEARTBEAT_MINUTES_DEFAULT);
```

Et plus bas, avec les autres lignes de log :

```c
MyMod_Log.Info("Settings loaded: HeartbeatMinutes = " + settings.HeartbeatMinutes.ToString());
```

## 8. Utiliser ce réglage

Ouvre `scripts/5_Mission/MyMod_MissionServer.c` et ajoute ces deux méthodes dans la classe :

```c
override void OnMissionStart()
{
    super.OnMissionStart();

    if (!MyMod_SettingsManager.Get().Enabled)
        return;

    // true: the message repeats at each interval.
    int delayMs = MyMod_SettingsManager.Get().HeartbeatMinutes * 60000;
    GetGame().GetCallQueue(CALL_CATEGORY_GAMEPLAY).CallLater(MyMod_Heartbeat, delayMs, true);
}

protected void MyMod_Heartbeat()
{
    MyMod_Log.Info("Server still running");
}
```

Le préfixe `MyMod_` sur le nom de la méthode évite un conflit avec un autre mod qui modifierait la même classe.

## 9. Tester le réglage

Lance la tâche **4. Test locally**, puis ouvre `build/profiles/server/MyMod/settings.json`. Ton réglage y est apparu tout seul.

Essaie ces trois cas, en lançant **6. Close everything** puis **4. Test locally** entre chaque :

| Dans le JSON | Ce que le log doit dire |
|---|---|
| `"HeartbeatMinutes": 1` | `Server still running` chaque minute |
| `"HeartbeatMinutes": 500` | Une ligne `WARNING` : hors limites, retour à 5 |
| Supprime une accolade du fichier | Une ligne `ERROR` : fichier illisible, valeurs par défaut, et le serveur démarre quand même |

Remets le fichier en état après le dernier essai : le mod ne réécrit jamais un fichier cassé, pour ne pas effacer le travail d'un admin.

## 10. Si ça ne marche pas

Une erreur de script apparaît en rouge dans le terminal, avec le fichier et la ligne. Les erreurs fréquentes sont dans la FAQ du [README](../README.fr.md).

## 11. Publier

1. Change la version dans `scripts/3_Game/MyMod_Version.c`, par exemple `1.0.1`. Tu n'as besoin de l'écrire nulle part ailleurs.
2. Lance la tâche **7. Prepare release**. Elle reconstruit le mod, crée `release/@MyMod` et le contrôle. Si elle affiche `PUBLISH BLOCKED`, corrige ce qu'elle indique et relance-la.
3. Ouvre **DayZ Tools** depuis Steam, puis **Publisher**.
4. Choisis `release/@MyMod`, ajoute un titre, une description et une image d'aperçu, puis publie.
5. Sur ta page Workshop, rappelle aux admins de copier le contenu de `keys/` dans le dossier `keys/` de leur serveur.

Pour une mise à jour, reprends ces étapes en changeant le numéro de version, et garde les mêmes clés.

## Pour publier ton code sur GitHub

`.gitignore` bloque déjà les clés, les logs et les fichiers générés. Avant de pousser, lance la tâche **8. Check before publishing** : elle contrôle aussi les fichiers suivis par git.
