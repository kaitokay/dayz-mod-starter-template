// Default value and limits of each setting.
class MyMod_SettingsLimits
{
    static const int EXAMPLE_VALUE_DEFAULT = 10;
    static const int EXAMPLE_VALUE_MIN     = 0;
    static const int EXAMPLE_VALUE_MAX     = 100;
};

// The variables are the JSON keys.
class MyMod_Settings
{
    bool Enabled = true;
    int  ExampleValue = MyMod_SettingsLimits.EXAMPLE_VALUE_DEFAULT;
};

// File: profiles/MyMod/settings.json on the server.
class MyMod_SettingsManager
{
    static const string FOLDER = "$profile:MyMod";
    static const string PATH   = "$profile:MyMod/settings.json";

    protected static ref MyMod_Settings s_Current;

    // Default values until Load() has been called.
    static MyMod_Settings Get()
    {
        if (!s_Current)
            s_Current = new MyMod_Settings();
        return s_Current;
    }

    // Never crashes, even with a broken file.
    static void Load()
    {
        MyMod_Settings settings = new MyMod_Settings();
        string error;

        if (!FileExist(PATH))
        {
            MakeDirectory(FOLDER);
            if (JsonFileLoader<MyMod_Settings>.SaveFile(PATH, settings, error))
                MyMod_Log.Info("Settings: file created with default values");
            else
                MyMod_Log.Err("Settings: cannot create the file, using default values. " + error);
        }
        else if (JsonFileLoader<MyMod_Settings>.LoadFile(PATH, settings, error))
        {
            // Rewritten so new settings show up, keeping the admin's values.
            if (!JsonFileLoader<MyMod_Settings>.SaveFile(PATH, settings, error))
                MyMod_Log.Warn("Settings: cannot update the file. " + error);
        }
        else
        {
            // Broken file: never overwrite it, the admin would lose their work.
            MyMod_Log.Err("Settings: unreadable file, using default values. " + error);
            settings = new MyMod_Settings();
        }

        settings.ExampleValue = CheckInt("ExampleValue", settings.ExampleValue, MyMod_SettingsLimits.EXAMPLE_VALUE_MIN, MyMod_SettingsLimits.EXAMPLE_VALUE_MAX, MyMod_SettingsLimits.EXAMPLE_VALUE_DEFAULT);
        s_Current = settings;

        MyMod_Log.Info("Settings loaded: Enabled = " + settings.Enabled.ToString());
        MyMod_Log.Info("Settings loaded: ExampleValue = " + settings.ExampleValue.ToString());
    }

    // Out of range: log it and go back to the default value.
    protected static int CheckInt(string name, int value, int minValue, int maxValue, int defaultValue)
    {
        if (value >= minValue && value <= maxValue)
            return value;

        MyMod_Log.Warn("Settings: " + name + " = " + value.ToString() + " is out of range (" + minValue.ToString() + " to " + maxValue.ToString() + "), using " + defaultValue.ToString());
        return defaultValue;
    }
};
