// Credit to Bartic77 and Mythicy for previous versions of this autosplitter.

state("GSR") { }
state("GSE") { }
state("mGBA") { }

startup
{
    settings.Add("roxanne", true, "Rustboro City Gym (Roxanne)");
    settings.Add("slateport", true, "Arrive at Slateport");
    settings.Add("rival_2", true, "2nd Rival Battle");
    settings.Add("wattson", true, "Mauville City Gym (Watson)");
    settings.Add("maxie_1", true, "1st Maxie Fight");
    settings.Add("flannery", true, "Lavaridge Town Gym (Flannery)");
    settings.Add("brawly", true, "Dewford Town Gym (Brawly)");
    settings.Add("norman", true, "Petalburg City Gym (Norman)");
    settings.Add("rival_3", true, "3rd Rival Battle");
    settings.Add("winona", true, "Fortree City Gym (Winona)");
    settings.Add("maxie_2", true, "2nd Maxie Fight");
    settings.Add("tate_liza", true, "Mosdeep City Gym (Tate and Liza)");
    settings.Add("archie", true, "Archie Fight");
    settings.Add("juan", true, "Sootopolis City Gym (Juan)");
    settings.Add("sidney", true, "Elite 4 Sidney");
    settings.Add("phoebe", true, "Elite 4 Phoebe");
    settings.Add("glacia", true, "Elite 4 Glacia");
    settings.Add("drake", true, "Elite 4 Drake");
    settings.Add("wallace", true, "Elite 4 Wallace");
    settings.Add("hof", true, "Hall of Fame");

    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("GBA");

    vars.Helper.Load = (Func<dynamic, bool>)(emu =>
    {
        uint gSaveBlock1PtrAddr = 0x03005D8C;
        uint gSaveBlock2PtrAddr = 0x03005D90;
        emu.Make<ushort>("newKeys", 0x030022EE); // A = 1, B = 2, start = 8, sel = 4
        emu.Make<uint>("gTasks", 0x03005e00);
        emu.Make<byte>("cursorPos", 0x03005e00 + 0xA);
        emu.Make<uint>("igt", gSaveBlock2PtrAddr, 0x0E);
        emu.Make<ushort>("gTrainerBattleOpponent_A", 0x02038bca); // opp trainer id
        emu.Make<byte>("fadeDelayCounter", 0x02037FD9); // gPaletteFade + 5
        emu.Make<ushort>("fadeTarget", 0x02037FDA); // gPaletteFade + 6
        emu.Make<byte>("hofFadeVariable", 0x02037FDD); // gPaletteFade + 9
        emu.Make<byte>("oppFaintCounter", 0x03005d11); // gBattleResults.opponentFaintCounter

        emu.Make<ushort>("xCoord", gSaveBlock1PtrAddr, 0);
        emu.Make<ushort>("yCoord", gSaveBlock1PtrAddr, 2);
        emu.Make<byte>("mapGroup", gSaveBlock1PtrAddr, 4);
        emu.Make<byte>("mapNumber", gSaveBlock1PtrAddr, 5);
        return true;
    });

    vars.Current = (Func<string, uint, bool>)((name, value) =>
    {
        return vars.Helper[name].Current == value;
    });

    vars.PrintVar = (Func<string, Action>)(name =>
    {
        print(vars.Helper[name].Current.ToString());
        return;
    });

    vars.PrintHex = (Func<string, Action>)(name =>
    {
        print(vars.Helper[name].Current.ToString("X"));
        return;
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
    {
        Func<uint, byte, bool> BattleIsOver = (enemyTrainerID, enemyPartyCount) => {
            return (vars.Current("gTrainerBattleOpponent_A", enemyTrainerID)
            && vars.Current("fadeDelayCounter", 0)
            && vars.Current("fadeTarget", 0xFFFF)
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
            {"rival_2", BattleIsOver(521, 3)},
            {"slateport", IsOnTile(0, 0x18, 0x15, 0x18)},
            {"wattson", BattleIsOver(267, 4)},
            {"maxie_1", BattleIsOver(602, 3)},
            {"flannery", BattleIsOver(268, 4)},
            {"brawly", BattleIsOver(266, 3)},
            {"norman", BattleIsOver(269, 4)},
            {"rival_3", BattleIsOver(522, 3)},
            {"winona", BattleIsOver(270, 5)},
            {"maxie_2", BattleIsOver(601, 3)},
            {"tate_liza", BattleIsOver(271, 4)},
            {"archie", BattleIsOver(34, 3)},
            {"juan", BattleIsOver(272, 5)},
            {"sidney", BattleIsOver(261, 5)},
            {"phoebe", BattleIsOver(262, 5)},
            {"glacia", BattleIsOver(263, 5)},
            {"drake", BattleIsOver(264, 5)},
            {"wallace", BattleIsOver(335, 6)},
            {"hof", IsOnTile(0x10, 0xB, 7, 5) && vars.Current("hofFadeVariable", 0x10) && vars.Current("gTasks", 0x081740B1)},
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
    return current.gTasks == 0x0803024D && (current.newKeys & 1) == 1 && current.igt == 0 && current.cursorPos == 0;
}