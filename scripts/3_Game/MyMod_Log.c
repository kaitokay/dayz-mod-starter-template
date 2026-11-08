// The prefix makes the mod easy to filter in the logs.
class MyMod_Log
{
    static const string PREFIX = "[MyMod] ";

    static void Info(string message)
    {
        Print(PREFIX + message);
    }

    static void Warn(string message)
    {
        Print(PREFIX + "WARNING: " + message);
    }

    static void Err(string message)
    {
        Print(PREFIX + "ERROR: " + message);
    }
};
