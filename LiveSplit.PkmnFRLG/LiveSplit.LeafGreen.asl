state("GSR") { }
state("mGBA") { }

startup {

    settings.Add("rival_1", false, "First Rival");
    settings.Add("brock", true, "Brock");
    settings.Add("moonExit", false, "Exit Mt. Moon");
    settings.Add("misty", true, "Misty");
    settings.Add("bill", true, "Bill");
    settings.Add("bike", false, "Bicycle");
    settings.Add("surge", true, "Lt. Surge");
    settings.Add("enterTunnel", true, "Enter Rock Tunnel");
    settings.Add("exitTunnel", false, "Exit Rock Tunnel");
    settings.Add("exitLavenderShop", true, "Exit Lavender Shop");
    settings.Add("giovanni_1", true, "Giovanni 1");
    settings.Add("flute", true, "Pokeflute");
    settings.Add("koga", true, "Koga");
    settings.Add("blaine", true, "Blaine");
    settings.Add("erika", true, "Erika");
    settings.Add("sabrina", true, "Sabrina");
    settings.Add("giovanni_3", true, "Giovanni 3");
    settings.Add("lorelei", true, "Lorelei");
    settings.Add("bruno", true, "Bruno");
    settings.Add("agatha", true, "Agatha");
    settings.Add("lance", true, "Lance");
    settings.Add("champion", true, "Champion");
    settings.Add("hof", true, "Hall of Fame");

    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("GBA");
    vars.Helper.Load = (Func<dynamic, bool>)(emu =>
    {
        uint saveBlock1PtrAddr = 0x03005008;
        uint saveBlock2PtrAddr = 0x0300500c;

        emu.Make<ushort>("newKeys", 0x030030F0 + 0x2E); // gMain
        emu.Make<uint>("gTasks", 0x03005090);
        emu.Make<byte>("cursorPos", 0x0300509A);
        emu.Make<ushort>("gTrainerBattleOpponent_A", 0x020386ae);
        emu.Make<ushort>("fadeTargetY", 0x02037AB8 + 0x8); // gPaletteFade.targetY
        emu.Make<ushort>("fadeBlendColor", 0x02037AB8 + 0xA); // gPaletteFade.blendColor
        emu.Make<byte>("oppFaintCounter", 0x03004F91); // gBattlResults
        emu.Make<ushort>("xCoord", saveBlock1PtrAddr, 0);
        emu.Make<ushort>("yCoord", saveBlock1PtrAddr, 2);
        emu.Make<byte>("mapGroup", saveBlock1PtrAddr, 4);
        emu.Make<byte>("mapNumber", saveBlock1PtrAddr, 5);
        emu.Make<ushort>("sFanfareCounter", 0x03000fc6);

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

    vars.PrintPos = (Func<Action>)(() => {
        print("Map Group: " + vars.Helper["mapGroup"].Current.ToString("X") +
        ", Map Number: " + vars.Helper["mapNumber"].Current.ToString("X") +
        ", (" + vars.Helper["xCoord"].Current.ToString("X") +
        ", " + vars.Helper["yCoord"].Current.ToString("X") + ")");
        return;
    });

    vars.IsOnTile = (Func<byte, byte, ushort, ushort, bool>)((MapGroup, MapNumber, X, Y) =>
    {
        return (vars.Helper["mapGroup"].Current == MapGroup
        && vars.Helper["mapNumber"].Current == MapNumber
        && vars.Helper["xCoord"].Current == X
        && vars.Helper["yCoord"].Current == Y
        );
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
    {
        bool trainerFadeBlack = vars.Current("fadeBlendColor", 0x0012) && ((vars.Helper["fadeTargetY"].Current & 0xFF) == 0x43);
        bool mapFadeBlack = vars.Current("fadeBlendColor", 0x0012) && vars.Helper["fadeTargetY"].Current >= 0x1000;
        bool keyItemJingle = vars.Helper["sFanfareCounter"].Current <= 0x90 && vars.Helper["sFanfareCounter"].Current != 0;
        bool shortJingle = vars.Helper["sFanfareCounter"].Current <= 0x40 && vars.Helper["sFanfareCounter"].Current != 0;
        Func<uint, byte, bool> BattleIsOver = (enemyTrainerID, enemyPartyCount) => {
            return (vars.Current("gTrainerBattleOpponent_A", enemyTrainerID)
            && trainerFadeBlack
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
            {"rival_1", BattleIsOver(327, 1)},
            {"brock", BattleIsOver(414, 2)},
            {"moonExit", IsOnTile(1, 2, 0x2D, 4) && mapFadeBlack},
            {"misty", BattleIsOver(415, 2)},
            {"bill", IsOnTile(0x1E, 0, 6, 4) && shortJingle},
            {"bike", (IsOnTile(7, 6, 7, 3) || IsOnTile(7, 6, 9, 5)) && keyItemJingle},
            {"surge", BattleIsOver(416, 3)},
            {"enterTunnel", IsOnTile(3, 0x1C, 8, 0x13) && mapFadeBlack},
            {"exitTunnel", IsOnTile(1, 0x51, 0x12, 0x25) && mapFadeBlack},
            {"exitLavenderShop", IsOnTile(8, 5, 4, 7) && mapFadeBlack && vars.enteredLavenderMart},
            {"giovanni_1", BattleIsOver(348, 3)},
            {"flute", IsOnTile(8, 2, 4, 3) && keyItemJingle},
            {"koga", BattleIsOver(418, 4)},
            {"blaine", BattleIsOver(419, 4)},
            {"erika", BattleIsOver(417, 3)},
            {"sabrina", BattleIsOver(420, 4)},
            {"giovanni_3", BattleIsOver(350, 5)},
            {"lorelei", BattleIsOver(410, 5)},
            {"bruno", BattleIsOver(411, 5)},
            {"agatha", BattleIsOver(412, 5)},
            {"lance", BattleIsOver(413, 5)},
            {"champion", BattleIsOver(439,6)},
            {"hof", vars.Current("gTasks", 0x080F28DD) && mapFadeBlack},

        };
    });
}

update
{
    if(timer.CurrentPhase == TimerPhase.NotRunning && vars.pastSplits.Count > 0) {
        vars.pastSplits.Clear();
    }

    if(!vars.enteredLavenderMart && vars.IsOnTile(8, 5, 4, 6)) {
        vars.enteredLavenderMart = true;
    }
}

init
{
    refreshRate = 200 / 3.0;
    vars.pastSplits = new HashSet<string>();
    vars.enteredLavenderMart = false;
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
    return current.gTasks == 0x0800CA69 && (current.newKeys & 1) == 1 && current.cursorPos == 1;
}