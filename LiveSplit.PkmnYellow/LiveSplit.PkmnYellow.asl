state("GSR") { }
state("GSE") { }
state("gambatte_speedrun") { }

startup
{
    //-------------------------------------------------------------//
    settings.Add("battles", true, "Battles");
    settings.Add("other", true, "Other");

    settings.CurrentDefaultParent = "battles";
    settings.Add("nidoran", true, "Viridian Forest House");
    settings.Add("silphGiovanni", true, "Silph Co. (Giovanni)");
    settings.Add("nuggetBridge", true, "Nugget Bridge (Rocket)");
    settings.Add("gym1", true, "Pewter Gym (Brock)");
    settings.Add("gym2", true, "Cerulean Gym (Misty)");
    settings.Add("gym3", true, "Vermilion Gym (Lt. Surge)");
    settings.Add("gym4", true, "Celadon Gym (Erika)");
    settings.Add("gym5", true, "Fuchsia Gym (Koga)");
    settings.Add("gym6", true, "Saffron Gym (Sabrina)");
    settings.Add("gym7", true, "Cinnabar Gym (Blaine)");
    settings.Add("gym8", true, "Viridian Gym (Giovanni)");
    settings.Add("elite4_1", true, "Lorelei");
    settings.Add("elite4_2", true, "Bruno");
    settings.Add("elite4_3", true, "Agatha");
    settings.Add("elite4_4", true, "Lance");
    settings.Add("elite4_5", true, "Champion");

    settings.CurrentDefaultParent = "other";
    settings.Add("rival", false, "Leave Oak's Lab (after rival fight)");
    settings.Add("enterMtMoon", true, "Enter Mt. Moon");
    settings.Add("exitMtMoon", true, "Exit Mt. Moon");
    settings.Add("exitViridianForest", true, "Exit Viridian Forest");
    settings.Add("exitVictoryRoad", true, "Exit Victory Road");
    settings.Add("hm02", true, "Obtain HM02");
    settings.Add("flute", true, "Obtain Poké Flute");
    settings.Add("hm03", false, "Obtain HM03");
    settings.Add("enterMansion", false, "Enter Pokemon Mansion");
    settings.Add("hof", true, "HoF Fade Out");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("GBC");
    vars.Helper.Load = (Func<dynamic, bool>)(emu =>
    {
        emu.Make<byte>("wSoundID", 0x0001);
        emu.Make<byte>("hofTile", 0x0490);
        emu.Make<byte>("wCurrentMenuItem", 0x0C26);
        emu.Make<uint>("wHoFMonOrPlayer", 0x0D40);
        emu.Make<byte>("wEnemyMonSpecies2", 0x0FD7);
        emu.Make<uint>("wEnemyMonNick", 0x0FD9);
        emu.Make<uint>("wTrainerName", 0x1049);
        emu.Make<byte>("wPartyCount", 0x1162);
        emu.Make<ushort>("wPlayerID", 0x1358);
        emu.Make<byte>("wCurMap", 0x135D);
        emu.Make<byte>("wYCoord", 0x1360);
        emu.Make<byte>("wXCoord", 0x1361);
        emu.Make<ushort>("wStack", 0x1FFD);

        // iohram starts 0xff00
        emu.Make<byte>("rBGP", 0xFF47);
        emu.Make<byte>("hJoyHeld", 0xFFB4);

        return true;
    });

    vars.Current = (Func<string, uint, bool>)((name, value) =>
    {
        return vars.Helper[name].Current == value;
    });

    vars.IsOnTile = (Func<byte, byte, byte, bool>)((MapID, YCoord, XCoord) =>
    {
        return vars.Current("wCurMap", MapID) && vars.Current("wYCoord", YCoord) && vars.Current("wXCoord", XCoord);
    });

    var enterMapBreakpoint = 0xDF01u;
    var itemJingleID = 0x94u;

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
    {
        bool battleOver = vars.Current("wEnemyMonSpecies2", 0) && vars.Current("wStack", enterMapBreakpoint);
        bool fadeWhite = vars.Current("rBGP", 0);
        return new Dictionary<string, bool> {
            {"nidoran", vars.IsOnTile(0x32, 0x2B, 0x03)},
            {"nuggetBridge", vars.Current("wTrainerName", 0x918E828A) && vars.Current("wCurMap", 0x23) && battleOver},
            {"silphGiovanni", vars.Current("wTrainerName", 0x86888E95) && vars.Current("wCurMap", 0xEB) && battleOver},
            {"gym1", vars.Current("wTrainerName", 0x81918E82) && battleOver},
            {"gym2", vars.Current("wTrainerName", 0x8C889293) && battleOver},
            {"gym3", vars.Current("wTrainerName", 0x8B93E892) && battleOver},
            {"gym4", vars.Current("wTrainerName", 0x8491888A) && battleOver},
            {"gym5", vars.Current("wTrainerName", 0x8A8E8680) && battleOver},
            {"gym6", vars.Current("wTrainerName", 0x92808191) && battleOver},
            {"gym7", vars.Current("wTrainerName", 0x818B8088) && battleOver},
            {"gym8", vars.Current("wTrainerName", 0x86888E95) && vars.Current("wCurMap", 0x2D) && battleOver},
            {"elite4_1", vars.Current("wTrainerName", 0x8B8E9184) && battleOver},
            {"elite4_2", vars.Current("wTrainerName", 0x8191948D) && battleOver},
            {"elite4_3", vars.Current("wTrainerName", 0x80868093) && battleOver},
            {"elite4_4", vars.Current("wTrainerName", 0x8B808D82) && battleOver},
            {"elite4_5", (vars.Current("wEnemyMonNick", 0x858B8091) || vars.Current("wEnemyMonNick", 0x95808F8E)) && vars.Current("wCurMap", 0x78) && battleOver},

            {"rival", vars.Current("wCurMap", 0) && vars.Current("wPartyCount", 1)},
            {"enterMtMoon", vars.IsOnTile(0x3B, 0x05, 0x12)},
            {"exitMtMoon", vars.IsOnTile(0x0F, 0x03, 0x1B)},
            {"exitVictoryRoad", vars.IsOnTile(0x22, 0x1F, 0x0E)},
            {"exitViridianForest", vars.IsOnTile(0x2F, 0x07, 0x04)},
            {"hm02", vars.Current("wSoundID", itemJingleID) && vars.Current("wCurMap", 0xBC)},
            {"flute", vars.Current("wSoundID", itemJingleID) && vars.Current("wCurMap", 0x95)},
            {"hm03", vars.Current("wSoundID", itemJingleID) && vars.Current("wCurMap", 0xDE)},

            {"hof", vars.Current("wCurMap", 0x76) && vars.Current("wHoFMonOrPlayer", 0x01000000) && vars.Current("hofTile", 0x79) && fadeWhite},
        };
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
}

init {
    vars.pastSplits = new HashSet<string>();
    refreshRate = 200 / 3.0;
}

update
{
    if(timer.CurrentPhase == TimerPhase.NotRunning && vars.pastSplits.Count > 0) {
        vars.pastSplits.Clear();
    }
}

start {
    return current.wCurrentMenuItem == 0 && current.wPlayerID == 0 && current.wStack == 0x435C && (current.hJoyHeld & 0x80) == 0;
}

reset {
    return current.wCurrentMenuItem == 1 && current.wPlayerID == 0 && current.wStack == 0x435C;
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

exit {
    refreshRate = 0.5;
}

