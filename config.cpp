class CfgPatches
{
    class MyMod
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 0.1;
        requiredAddons[] = {"DZ_Data", "DZ_Scripts"};
    };
};

class CfgMods
{
    class MyMod
    {
        dir = "MyMod";
        name = "MyMod";
        type = "mod";
        dependencies[] = {"Game", "World", "Mission"};

        class defs
        {
            class gameScriptModule    { value = ""; files[] = {"MyMod/scripts/3_Game"}; };
            class worldScriptModule   { value = ""; files[] = {"MyMod/scripts/4_World"}; };
            class missionScriptModule { value = ""; files[] = {"MyMod/scripts/5_Mission"}; };
        };
    };
};
