// Client entry point.
modded class MissionGameplay
{
    override void OnInit()
    {
        super.OnInit();
        MyMod_Log.Info("Client started, version " + MyMod_Version.NUMBER);
    }
};
