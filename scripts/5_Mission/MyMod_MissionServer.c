// Server entry point.
modded class MissionServer
{
    override void OnInit()
    {
        super.OnInit();
        MyMod_Log.Info("Server started, version " + MyMod_Version.NUMBER);
        MyMod_SettingsManager.Load();
    }

    override void InvokeOnConnect(PlayerBase player, PlayerIdentity identity)
    {
        super.InvokeOnConnect(player, identity);

        if (!MyMod_SettingsManager.Get().Enabled)
            return;

        // The identity can be null if the player disconnects while connecting.
        if (!identity)
        {
            MyMod_Log.Warn("Player connected without identity");
            return;
        }

        MyMod_Log.Info("Player connected: " + identity.GetName());
    }
};
