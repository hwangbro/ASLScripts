state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("gambatte_speedrun") {}

startup {
    //-------------------------------------------------------------//
    settings.Add("all", true, "Glichless Any%");
    settings.CurrentDefaultParent = "all";
    settings.Add("falkner", true, "Violet Gym (Falkner)");
    settings.Add("unioncave", false, "Union Cave Exit");
    settings.Add("bugsy", true, "Azalea Gym (Bugsy)");
    settings.Add("whitney", true, "Goldenrod Gym (Whitney)");
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
    settings.Add("erika", true, "Celadon Gym (Erika)");
    settings.Add("sabrina", true, "Saffron Gym (Sabrina)");
    settings.Add("misty", true, "Cerulean Gym (Misty)");
    settings.Add("surge", true, "Vermillion Gym (Lt. Surge)");
    settings.Add("brock", true, "Pewter Gym (Brock)");
    settings.Add("blaine", true, "Cinnabar Gym (Blaine)");
    settings.Add("janine", true, "Fuschia Gym (Janine)");
    settings.Add("blue", true, "Viridian Gym (Blue)");
    settings.Add("red", true, "Red Fight (End of Game)");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    vars.timer_OnStart = (EventHandler)((s, e) => {
        vars.lastTrainer = 0;
        vars.splits = vars.GetSplitList();
        vars.ended = false;
    });
    timer.OnStart += vars.timer_OnStart;

    vars.TryFindOffsets = (Func<Process, bool>)((proc) => {
        print("[Autosplitter] Scanning memory");
        var target = new SigScanTarget(0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");

        int scanOffset = 0;
        foreach (var page in proc.MemoryPages()) {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
            if ((scanOffset = (int)scanner.Scan(target)) != 0) {
                break;
            }
        }

        if (scanOffset != 0) {
            var wramOffset = scanOffset - 0x10;
            vars.watchers = vars.GetWatcherList((int)(wramOffset - 0x400000), (IntPtr)(scanOffset + 0x147C), (IntPtr)(scanOffset + 0x1443));
            print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));

            return true;
        }

        return false;
    });

    vars.GetWatcherList = (Func<int, IntPtr, IntPtr, MemoryWatcherList>)((wramOffset, hramOffset, rBGP) => {
        return new MemoryWatcherList {
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1118)) { Name = "opponentClass" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0C12)) { Name = "battleEnded" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0FE9)) { Name = "battleResult" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x111B)) { Name = "trainerID" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x11A1)) { Name = "playerID" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1199)) { Name = "options" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0EAB)) { Name = "menuSelection" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x18B8)) { Name = "gameTimerPaused" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x01CD)) { Name = "inOverworld" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1A00)) { Name = "mapID" },

            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x01A8)) { Name = "musicFade" },

            new MemoryWatcher<byte>(rBGP) { Name = "rBGP" },
            new MemoryWatcher<byte>(hramOffset + 0x26) { Name = "inputPressed" },
            new MemoryWatcher<byte>(hramOffset + 0x2C) { Name = "inMenu" },

        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, uint>>>)(() => {
        return new Dictionary<string, Dictionary<string, uint>> {
            { "falkner", new Dictionary<string, uint> { { "opponentClass", 1u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "unioncave", new Dictionary<string, uint> { { "mapID", 0x0608u } } },
            { "bugsy", new Dictionary<string, uint> { { "opponentClass", 3u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "whitney", new Dictionary<string, uint> { { "opponentClass", 2u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "morty", new Dictionary<string, uint> { { "opponentClass", 4u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "chuck", new Dictionary<string, uint> { { "opponentClass", 7u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "pryce", new Dictionary<string, uint> { { "opponentClass", 5u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "jasmine", new Dictionary<string, uint> { { "opponentClass", 6u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "rival4", new Dictionary<string, uint> { { "opponentClass", 9u }, { "trainerID", 10u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "radioTower", new Dictionary<string, uint> { { "opponentClass", 0x33u }, { "trainerID", 1u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "clair", new Dictionary<string, uint> { { "opponentClass", 8u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "will", new Dictionary<string, uint> { { "opponentClass", 0x0Bu }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "koga", new Dictionary<string, uint> { { "opponentClass", 0x0Fu }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "bruno", new Dictionary<string, uint> { { "opponentClass", 0x0Du }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "karen", new Dictionary<string, uint> { { "opponentClass", 0x0Eu }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "lance", new Dictionary<string, uint> { { "opponentClass", 0x10u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "erika", new Dictionary<string, uint> { { "opponentClass", 0x15u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "sabrina", new Dictionary<string, uint> { { "opponentClass", 0x23u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "misty", new Dictionary<string, uint> { { "opponentClass", 0x12u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "surge", new Dictionary<string, uint> { { "opponentClass", 0x13u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "brock", new Dictionary<string, uint> { { "opponentClass", 0x11u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "blaine", new Dictionary<string, uint> { { "opponentClass", 0x2Eu }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "janine", new Dictionary<string, uint> { { "opponentClass", 0x1Au }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "blue", new Dictionary<string, uint> { { "opponentClass", 0x40u }, { "battleResult", 0u }, { "battleEnded", 1u }, { "rBGP", 0u } } },
            { "red", new Dictionary<string, uint> { { "opponentClass", 0x3Fu }, { "battleResult", 0u }, { "inOverworld", 1u }, { "musicFade", 2u }, { "rBGP", 0u } } },
        };
    });
}

init {
    vars.lastTrainer = 0;
    vars.ended = false;

    vars.watchers = new MemoryWatcherList();
    vars.splits = new Dictionary<string, Dictionary<string, uint>>();

    if (!vars.TryFindOffsets(game)) {
        throw new Exception("Emulated memory not yet initialized.");
    } else {
        refreshRate = 200/3.0;
    }
}

update {
    vars.watchers.UpdateAll(game);
    if (vars.watchers["opponentClass"].Current != vars.watchers["opponentClass"].Old) {
        vars.lastTrainer = vars.watchers["opponentClass"].Old;
    }

    // reset lastTrainer if hard/soft reset
    if (vars.watchers["playerID"].Current == 0) {
        vars.lastTrainer = 0;
    }
}

start {
    return ((vars.watchers["options"].Current & 7) == 1 &&
        vars.watchers["menuSelection"].Current == 1 &&
        vars.watchers["inputPressed"].Current == 1 &&
        vars.watchers["inMenu"].Current == 0 &&
        vars.watchers["gameTimerPaused"].Current == 0);
}

split {
    foreach (var _split in vars.splits) {
        if (settings[_split.Key]) {
            var count = 0;
            foreach (var _condition in _split.Value) {
                if (vars.watchers[_condition.Key].Current == _condition.Value) {
                    count++;
                } else if (_condition.Key == "opponentClass" && _condition.Value == vars.lastTrainer) {
                    count++;
                } else if (_condition.Key == "musicFade" && vars.watchers[_condition.Key].Current == 1) {
                    count++;
                }
            }

            if (count == _split.Value.Count) {
                print("[Autosplitter] Split: " + _split.Key);
                vars.splits.Remove(_split.Key);
                return true;
            }
        }
    }
}

exit {
    refreshRate = 0.5;
}

shutdown {
    timer.OnStart -= vars.timer_OnStart;
}