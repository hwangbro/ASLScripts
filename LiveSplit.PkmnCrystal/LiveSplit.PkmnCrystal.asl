state("GSR") { }
state("GSE") { }
state("gambatte_speedrun") { }

startup {
    //-------------------------------------------------------------//
    settings.Add("all", true, "Any% Glichless");
    settings.CurrentDefaultParent = "all";
    settings.Add("falkner", true, "Violet Gym (Falkner)");
    settings.Add("bugsy", true, "Azalea Gym (Bugsy)");
    settings.Add("whitney", true, "Goldenrod Gym (Whitney)");
    settings.Add("rival3", true, "Rival 3 (Burnt Tower)");
    settings.Add("morty", true, "Ecruteak Gym (Morty)");
    settings.Add("chuck", true, "Cianwood Gym (Chuck)");
    settings.Add("pryce", true, "Mahogany Gym (Pryce)");
    settings.Add("jasmine", true, "Olivine Gym (Jasmine)");
    settings.Add("rival4", true, "Rival 4 (Goldenrod Underground)");
    settings.Add("radioTower", true, "Radio Tower");
    settings.Add("clair", true, "Blackthorn Gym (Clair)");
    settings.Add("will", true, "Will");
    settings.Add("koga", true, "Koga");
    settings.Add("bruno", true, "Bruno");
    settings.Add("karen", true, "Karen");
    settings.Add("lance", true, "Lance");

    // Kanto
    settings.Add("misty", true, "Cerulean Gym (Misty)");
    settings.Add("surge", true, "Vermillion Gym (Lt. Surge)");
    settings.Add("blaine", true, "Cinnabar Gym (Blaine)");
    settings.Add("janine", true, "Fuschia Gym (Janine)");
    settings.Add("erika", true, "Celadon Gym (Erika)");
    settings.Add("blue", true, "Viridian Gym (Blue)");
    settings.Add("sabrina", true, "Saffron Gym (Sabrina)");
    settings.Add("brock", true, "Pewter Gym (Brock)");
    settings.Add("red", true, "Red Fight (End of Game)");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("GBC");

    vars.Helper.Load = (Func<dynamic, bool>)(emu =>
    {
        emu.Make<byte>("wOtherTrainerClass", 0x122F);
        emu.Make<byte>("wBattleEnded", 0x0734);
        emu.Make<byte>("wBattleResult", 0x10EE);
        emu.Make<byte>("wOtherTrainerID", 0x1231);
        emu.Make<ushort>("wPlayerID", 0x147B);
        emu.Make<byte>("wOptions", 0x0FCC);
        emu.Make<byte>("wMenuSelection", 0x0F74);
        emu.Make<byte>("wGameTimerPaused", 0x0FBC);
        emu.Make<byte>("wSpriteUpdatesEnabled", 0x02CE);
        emu.Make<byte>("wMusicFadeID", 0x02A8);


        emu.Make<byte>("rBGP", 0xFF47);
        emu.Make<byte>("hJoypadDown", 0xFFA4);
        emu.Make<byte>("hInMenu", 0xFFAA);
        return true;
    });

    vars.Current = (Func<string, uint, bool>)((name, value) =>
    {
        return vars.Helper[name].Current == value;
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
    {
        bool fadeWhite = vars.Current("rBGP", 0);
        bool battleOver = vars.Current("wBattleEnded", 1) && vars.Current("wBattleResult", 0) && vars.Current("wSpriteUpdatesEnabled", 0) && fadeWhite;
        return new Dictionary<string, bool> {
            {"falkner", vars.lastTrainer == 1 && battleOver},
            {"bugsy", vars.lastTrainer == 3 && battleOver},
            {"whitney", vars.lastTrainer == 2 && battleOver},
            {"rival3", vars.lastTrainer == 9 && vars.Current("wOtherTrainerID", 7) && battleOver},
            {"morty", vars.lastTrainer == 4 && battleOver},
            {"chuck", vars.lastTrainer == 7 && battleOver},
            {"pryce", vars.lastTrainer == 5 && battleOver},
            {"jasmine", vars.lastTrainer == 6 && battleOver},
            {"rival4", vars.lastTrainer == 9 && vars.Current("wOtherTrainerID", 10) && battleOver},
            {"radioTower", vars.lastTrainer == 0x33 && vars.Current("wOtherTrainerID", 1) && battleOver},
            {"clair", vars.lastTrainer == 8 && battleOver},
            {"will", vars.lastTrainer == 0xB && battleOver},
            {"koga", vars.lastTrainer == 0xF && battleOver},
            {"bruno", vars.lastTrainer == 0xD && battleOver},
            {"karen", vars.lastTrainer == 0xE && battleOver},
            {"lance", vars.lastTrainer == 0x10 && battleOver},
            {"erika", vars.lastTrainer == 0x15 && battleOver},
            {"sabrina", vars.lastTrainer == 0x23 && battleOver},
            {"misty", vars.lastTrainer == 0x12 && battleOver},
            {"surge", vars.lastTrainer == 0x13 && battleOver},
            {"brock", vars.lastTrainer == 0x11 && battleOver},
            {"blaine", vars.lastTrainer == 0x2E && battleOver},
            {"janine", vars.lastTrainer == 0x1A && battleOver},
            {"blue", vars.lastTrainer == 0x40 && battleOver},
            {"red", vars.lastTrainer == 0x3F && vars.Current("wBattleResult", 0) && vars.Current("wSpriteUpdatesEnabled", 1) && (vars.Helper["wMusicFadeID"].Current == 2 || vars.Helper["wMusicFadeID"].Current == 1) && fadeWhite},
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
    vars.lastTrainer = 0;
}

update
{
    if(timer.CurrentPhase == TimerPhase.NotRunning && vars.pastSplits.Count > 0) {
        vars.pastSplits.Clear();
    }

    if (current.wOtherTrainerClass != old.wOtherTrainerClass) {
        vars.lastTrainer = old.wOtherTrainerClass;
    }

    // reset lastTrainer if hard/soft reset
    if (current.wPlayerID == 0) {
        vars.lastTrainer = 0;
    }
}

start {
    return ((current.wOptions & 7) == 1) &&
        current.wMenuSelection == 1 &&
        current.hJoypadDown == 1 &&
        current.hInMenu == 0 &&
        current.wGameTimerPaused == 0;
}

reset
{
    return current.wPlayerID == 0 && current.hJoypadDown == 70;
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
