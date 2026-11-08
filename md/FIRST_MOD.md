# Your first mod, step by step

[Version française](PREMIER_MOD.md)

Allow about an hour if everything still needs installing. You don't need to know DayZ modding. Your mod will write a message to the server log at regular intervals, with a delay admins can configure. It's modest, but it takes you all the way through to publishing.

## 1. Install the tools

In Steam, install DayZ, then DayZ Server and DayZ Tools (under Tools in your library). Install [VS Code](https://code.visualstudio.com/) too.

Start DayZ once from Steam to check that it runs.

## 2. Get the project

Put this folder somewhere with no spaces in the path, for example `C:\Mods\MyMod`. In VS Code: **File > Open Folder**.

## 3. Check your install

Go to **Terminal > Run Task > 1. Check install**.

Each line tells you what was found. If a folder isn't detected, the message says what to do. The line about keys is normal at this stage: they're created on the first build.

## 4. Name your mod

Run **2. Rename mod** and type a name with no spaces or accents, for example `MyCoolMod`.

Then open `mod.cpp` and fill in your name and description. In the rest of this guide, `MyMod` means your mod: the rename updated this file too.

## 5. First build

Press **Ctrl+Shift+B**.

On the very first build, two keys are created in `%USERPROFILE%\DayZ-Mod-Keys\MyMod`:

- the `.bikey` is public and ships with your mod;
- the `.biprivatekey` is private and must never be shared.

Copy this folder to a USB stick or a vault. Without the private key, servers running your mod will have to install a new key at your next update.

## 6. First test

Open Steam, then run **4. Test locally**. The server opens in its own window, then the game starts and joins it by itself. Allow about 2 minutes, without touching anything.

In the terminal, you should see:

```
[MyMod] Server started, version 1.0.0
[MyMod] Settings: file created with default values
[MyMod] Settings loaded: Enabled = true
[MyMod] Settings loaded: ExampleValue = 10
[MyMod] Player connected: Survivor
```

When you're done, run **6. Close everything**.

Remember this loop, you'll repeat it often: change your scripts, run **6. Close everything**, then **4. Test locally**. That task rebuilds by itself. Nothing hot-reloads, so every change means running the test again.

## 7. Add your own setting

Open `scripts/3_Game/MyMod_Settings.c`.

Add the limits to `MyMod_SettingsLimits`:

```c
static const int HEARTBEAT_MINUTES_DEFAULT = 5;
static const int HEARTBEAT_MINUTES_MIN     = 1;
static const int HEARTBEAT_MINUTES_MAX     = 60;
```

Add the setting to `MyMod_Settings`. The variable name becomes the JSON key:

```c
int HeartbeatMinutes = MyMod_SettingsLimits.HEARTBEAT_MINUTES_DEFAULT;
```

In `Load()`, below the `settings.ExampleValue = CheckInt(...)` line, add the check:

```c
settings.HeartbeatMinutes = CheckInt("HeartbeatMinutes", settings.HeartbeatMinutes, MyMod_SettingsLimits.HEARTBEAT_MINUTES_MIN, MyMod_SettingsLimits.HEARTBEAT_MINUTES_MAX, MyMod_SettingsLimits.HEARTBEAT_MINUTES_DEFAULT);
```

And further down, with the other log lines:

```c
MyMod_Log.Info("Settings loaded: HeartbeatMinutes = " + settings.HeartbeatMinutes.ToString());
```

## 8. Use the setting

Open `scripts/5_Mission/MyMod_MissionServer.c` and add these two methods to the class:

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

The `MyMod_` prefix on the method name avoids a clash with another mod changing the same class.

## 9. Test the setting

Run **4. Test locally**, then open `build/profiles/server/MyMod/settings.json`. Your setting has appeared there on its own.

Try these three cases, running **6. Close everything** then **4. Test locally** between each:

| In the JSON | What the log should say |
|---|---|
| `"HeartbeatMinutes": 1` | `Server still running` every minute |
| `"HeartbeatMinutes": 500` | A `WARNING` line: out of range, back to 5 |
| Delete a brace from the file | An `ERROR` line: unreadable file, defaults used, and the server still starts |

Restore the file after the last test: the mod never overwrites a broken file, so it can't wipe an admin's work.

## 10. If something goes wrong

A script error shows up in red in the terminal, with the file and line. Common errors are covered in the [README](../README.md).

## 11. Publish

1. Change the version in `scripts/3_Game/MyMod_Version.c`, for example to `1.0.1`. You don't need to write it anywhere else.
2. Run **7. Prepare release**. It rebuilds the mod, creates `release/@MyMod` and checks it. If it shows `PUBLISH BLOCKED`, fix what it reports and run it again.
3. Open **DayZ Tools** from Steam, then **Publisher**.
4. Choose `release/@MyMod`, add a title, a description and a preview image, then publish.
5. On your Workshop page, remind admins to copy the contents of `keys/` into their server's `keys/` folder.

For an update, repeat these steps with a new version number, and keep the same keys.

## Publishing your code on GitHub

`.gitignore` already blocks keys, logs and generated files. Before pushing, run **8. Check before publishing**: it checks the files tracked by git too.
