// Credit to Bartic77 and Mythicy for previous versions of this autosplitter.

state("GSR") { }
state("mGBA") { }

startup
{
    settings.Add("roxanne", true, "Rustboro City Gym (Roxanne)");
    settings.Add("brawly", true, "Dewford Town Gym (Brawly)");
    settings.Add("rival_2", true, "2nd Rival Battle");
    settings.Add("wattson", true, "Mauville City Gym (Watson)");
    settings.Add("archie_1", true, "1st Archie Fight");
    settings.Add("flannery", true, "Lavaridge Town Gym (Flannery)");
    settings.Add("norman", true, "Petalburg City Gym (Norman)");
    settings.Add("rival_3", true, "3rd Rival Battle");
    settings.Add("winona", true, "Fortree City Gym (Winona)");
    settings.Add("tate_liza", true, "Mosdeep City Gym (Tate and Liza)");
    settings.Add("archie_3", true, "3rd Archie Fight");
    settings.Add("wallace", true, "Sootopolis City Gym (Wallace)");
    settings.Add("sidney", true, "Elite 4 Sidney");
    settings.Add("phoebe", true, "Elite 4 Phoebe");
    settings.Add("glacia", true, "Elite 4 Glacia");
    settings.Add("drake", true, "Elite 4 Drake");
    settings.Add("steven", true, "Elite 4 Steven");
    settings.Add("hof", true, "Hall of Fame");

    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("GBA");

    vars.Helper.Load = (Func<dynamic, bool>)(emu =>
    {
        uint gMain = 0x03001770;
        uint gTasks = 0x03004B20;
        uint gSaveBlock1 = 0x02025734;
        uint gSaveBlock2 = 0x02024EA4;
        uint gPaletteFade = 0x0202F388;
        uint gBattleResults = 0x030042E0;

        emu.Make<uint>("gTasks", gTasks);
        emu.Make<byte>("cursorPos", gTasks + 0xA);
        emu.Make<uint>("igt", gSaveBlock2 + 0xE);
        emu.Make<ushort>("gTrainerBattleOpponent", 0x0202FF5E);
        emu.Make<byte>("fadeDelayCounter", gPaletteFade + 5);
        emu.Make<ushort>("fadeTarget", gPaletteFade + 6);
        emu.Make<byte>("hofFadeVariable", gPaletteFade + 9);
        emu.Make<byte>("oppFaintCounter", gBattleResults + 1);

        emu.Make<ushort>("xCoord", gSaveBlock1);
        emu.Make<ushort>("yCoord", gSaveBlock1 + 2);
        emu.Make<byte>("mapGroup", gSaveBlock1 + 4);
        emu.Make<byte>("mapNumber", gSaveBlock1 + 5);
        return true;
    });

    vars.Current = (Func<string, uint, bool>)((name, value) =>
    {
        return vars.Helper[name].Current == value;
    });

    vars.PrintVar = (Func<string, Action>)(name =>
    {
        print(name + ": " + vars.Helper[name].Current.ToString());
        return;
    });

    vars.PrintHex = (Func<string, Action>)(name =>
    {
        print(name + ": " + vars.Helper[name].Current.ToString("X"));
        return;
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
    {
        Func<uint, byte, bool> BattleIsOver = (enemyTrainerID, enemyPartyCount) => {
            return (vars.Current("gTrainerBattleOpponent", enemyTrainerID)
            && vars.Current("fadeDelayCounter", 0)
            && (vars.Current("fadeTarget", 0x8000) || vars.Current("fadeTarget", 0xFFFF))
            && vars.Current("oppFaintCounter", enemyPartyCount)
            );
        };

        Func<byte, byte, ushort, ushort, bool> IsOnTile = (MapGroup, MapNumber, X, Y) => {
            return (vars.Current("mapGroup", MapGroup)
            && vars.Current("mapNumber", MapNumber)
            && vars.Current("xCoord", X)
            && vars.Current("yCoord", Y)
            );
        };

        return new Dictionary<string, bool> {
            {"roxanne", BattleIsOver(265, 2)},
            {"brawly", BattleIsOver(266, 2)},
            {"rival_2", BattleIsOver(521, 3)},
            {"wattson", BattleIsOver(267, 3)},
            {"archie_1", BattleIsOver(35, 3)},
            {"flannery", BattleIsOver(268, 3)},
            {"norman", BattleIsOver(269, 3)},
            {"rival_3", BattleIsOver(522, 3)},
            {"winona", BattleIsOver(270, 4)},
            {"tate_liza", BattleIsOver(271, 2)},
            {"archie_3", BattleIsOver(34, 3)},
            {"wallace", BattleIsOver(272, 5)},
            {"sidney", BattleIsOver(261, 5)},
            {"phoebe", BattleIsOver(262, 5)},
            {"glacia", BattleIsOver(263, 5)},
            {"drake", BattleIsOver(264, 5)},
            {"steven", BattleIsOver(335, 6)},
            {"hof", IsOnTile(0x10, 0xB, 7, 5) && vars.Current("hofFadeVariable", 0x10) && vars.Current("gTasks", 0x081428C1)}, // sub_81428A0, Task_Hof_HandleExit
        };
    });
}

update
{
    if(timer.CurrentPhase == TimerPhase.NotRunning && vars.pastSplits.Count > 0) {
        vars.pastSplits.Clear();
    }
}

init
{
    vars.pastSplits = new HashSet<string>();
}

split {
    var splits = vars.GetSplitList();

    foreach(var split in splits) {
        if (settings[split.Key] && split.Value && !vars.pastSplits.Contains(split.Key)) {
            vars.pastSplits.Add(split.Key);
            print("[AutoSplitter] Split: " + split.Key);
            return true;
        }
    }
}

start
{
    // Task_MainMenuPressedA
    return current.gTasks == 0x08009eb1 && current.igt == 0 && current.cursorPos == 0;
}