state("GSR") { }
state("GSE") { }
state("gambatte_speedrun") { }

startup
{
    //-------------------------------------------------------------//
    settings.Add("battles", true, "Battles");
    settings.Add("other", true, "Other");
    settings.Add("nsc", true, "NSC Only");
    settings.Add("subsplits", false, "Subsplits");

    settings.CurrentDefaultParent = "battles";
    settings.Add("nidoran", true, "Catch 2nd Pokemon (Nidoran/Spearow)");
    settings.Add("route3", false, "Route 3 Last Bug Catcher");
    settings.Add("hideoutGiovanni", false, "Hideout (Giovanni)");
    settings.Add("silphGiovanni", false, "Silph Co. (Giovanni)");
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
    settings.Add("exitVictoryRoad", false, "Exit Victory Road");
    settings.Add("hm02", true, "Obtain HM02");
    settings.Add("flute", true, "Obtain Poké Flute");
    settings.Add("hof", true, "HoF Fade Out");
    settings.Add("hofany", false, "Hof any%", "hof");

    settings.CurrentDefaultParent = "nsc";
    settings.Add("rival_one_start", false, "Rival 1 Tile");
    settings.Add("rival_one_end", false, "End of Rival 1");
    settings.Add("deathfly", false, "Deathfly");
    settings.Add("bc1", false, "Bug Catcher #1");
    settings.Add("bc2", false, "Bug Catcher #2");
    settings.Add("bc3", false, "Bug Catcher #3");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("GBC");
    vars.Helper.Load = (Func<dynamic, bool>)(emu =>
    {
        emu.Make<byte>("wSoundID", 0x0001);
        emu.Make<byte>("hofTile", 0x0490);
        emu.Make<byte>("wCurrentMenuItem", 0x0C26);
        emu.Make<uint>("wHoFMonOrPlayer", 0x0D40);
        emu.Make<byte>("wEnemyMonSpecies2", 0x0FD8);
        emu.Make<uint>("wEnemyMonNick", 0x0FDA);
        emu.Make<byte>("wBattleMonHP", 0x1016);
        emu.Make<uint>("wTrainerName", 0x104A);
        emu.Make<byte>("wTrainerNo", 0x105D);
        emu.Make<byte>("wPartyCount", 0x1163);
        emu.Make<ushort>("wPartyMon1Exp", 0x117A);
        emu.Make<ushort>("wPlayerID", 0x1359);
        emu.Make<byte>("wCurMap", 0x135E);
        emu.Make<byte>("wYCoord", 0x1361);
        emu.Make<byte>("wXCoord", 0x1362);
        emu.Make<ushort>("wStack", 0x1FFD);

        // iohram starts 0xff00
        emu.Make<byte>("rBGP", 0xFF47);
        emu.Make<byte>("hJoyHeld", 0xFFB4);
        emu.Make<ushort>("wTextDest", 0x0C3A);

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

    var enterMapBreakpoint = 0xAE03u;
    var itemJingleID = 0x94u;

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
    {
        bool battleOver = vars.Current("wEnemyMonSpecies2", 0) && vars.Current("wStack", enterMapBreakpoint);
        bool fadeWhite = vars.Current("rBGP", 0);
        return new Dictionary<string, bool> {
            {"nidoran", vars.Current("wCurMap", 0x21) && vars.Current("wPartyCount", 2) && vars.Current("wStack", enterMapBreakpoint)},
            {"route3", vars.Current("wTrainerName", 0x8194867F) && vars.Current("wTrainerNo", 6) && battleOver},
            {"nuggetBridge", vars.Current("wTrainerName", 0x918E828A) && vars.Current("wCurMap", 0x23) && battleOver},
            {"hideoutGiovanni", vars.Current("wTrainerName", 0x86888E95) && vars.Current("wCurMap", 0xCA) && battleOver},
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
            {"elite4_5", vars.Current("wEnemyMonNick", 0x95848D94) && vars.Current("wCurMap", 0x78) && battleOver},

            {"rival", vars.Current("wCurMap", 0) && vars.Current("wPartyCount", 1)},
            {"enterMtMoon", vars.IsOnTile(0x3B, 0x05, 0x12)},
            {"exitMtMoon", vars.IsOnTile(0x0F, 0x03, 0x1B)},
            {"exitVictoryRoad", vars.IsOnTile(0x22, 0x1F, 0x0E)},
            {"hm02", vars.Current("wSoundID", itemJingleID) && vars.Current("wCurMap", 0xBC)},
            {"flute", vars.Current("wSoundID", itemJingleID) && vars.Current("wCurMap", 0x95)},

            // hof
            {"hof", vars.Current("wCurMap", 0x76) && vars.Current("wHoFMonOrPlayer", 0x01000000) && vars.Current("hofTile", 0x79) && fadeWhite},
            {"hofany", vars.Current("wHoFMonOrPlayer", 0x01000C00) && vars.Current("wTextDest", 0xF2C4) && fadeWhite},

            // nsc
            {"rival_one_start", vars.IsOnTile(0x28, 0x06, 0x05) && vars.Current("wPartyCount", 1)},
            {"rival_one_end", vars.Current("wTrainerName", 0x91848350) && battleOver},
            {"bc1", vars.Current("wPartyMon1Exp", 0x00E0) && battleOver},
            {"bc2", vars.Current("wPartyMon1Exp", 0x0143) && battleOver},
            {"bc3", vars.IsOnTile(0x33, 0x21, 0x1D) && battleOver},
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
    return current.wCurrentMenuItem == 0 && current.wPlayerID == 0 && current.wStack == 0x915B && (current.hJoyHeld & 0x80) == 0;
}

reset {
    return current.wCurrentMenuItem == 1 && current.wPlayerID == 0 && current.wStack == 0x915B;
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
