state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("gambatte_speedrun") {}

startup {
    //-------------------------------------------------------------//
    settings.Add("battles", true, "Battles");
    settings.Add("other", true, "Other");

    settings.CurrentDefaultParent = "battles";
    settings.Add("nidoran", true, "Catch 2nd Pokemon (Nidoran/Spearow)");
    settings.Add("route3", false, "Route 3 Last Bug Catcher");
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
    settings.Add("exitVictoryRoad", true, "Exit Victory Road");
    settings.Add("hm02", true, "Obtain HM02");
    settings.Add("flute", true, "Obtain Poké Flute");
    settings.Add("hof", true, "HoF Fade Out");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    vars.timer_OnStart = (EventHandler)((s, e) => {
        vars.splits = vars.GetSplitList();
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
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0490)) { Name = "hofTile" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0C26)) { Name = "cursorIndex" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0D40)) { Name = "hofPlayerShown" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0FD8)) { Name = "enemyPkmn" },
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x0FDA)) { Name = "enemyPkmnName" },
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x104D)) { Name = "opponentName" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1060)) { Name = "opponentTrainerNo" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1168)) { Name = "partyCount" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x140C)) { Name = "playerID" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1411)) { Name = "mapIndex" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1414)) { Name = "playerPos" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1FFD)) { Name = "stack" },

            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x105F)) { Name = "gymLeaderNo" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1031)) { Name = "trainerClass" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1330)) { Name = "itemsInBag" },

            new MemoryWatcher<byte>(hramOffset + 0x34) { Name = "input" },
            new MemoryWatcher<byte>(rBGP) { Name = "rBGP" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, uint>>>)(() => {
        return new Dictionary<string, Dictionary<string, uint>> {
            { "nidoran", new Dictionary<string, uint> { { "partyCount", 2u }, { "stack", 0x03AEu } } },
            { "route3", new Dictionary<string, uint> { { "opponentName", 0x7FA6B481 }, { "opponentTrainerNo", 6u }, { "enemyPkmn", 0u }, {"stack", 0x03AEu } } },
            { "nuggetBridge", new Dictionary<string, uint> { { "opponentName", 0xAAA2AE91 }, { "mapIndex", 0x23u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "silphGiovanni", new Dictionary<string, uint> { { "opponentName", 0xB2B2AE81 }, { "mapIndex", 0xEBu }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym1", new Dictionary<string, uint> { { "opponentName", 0xA3A0A48B }, { "gymLeaderNo", 1u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym2", new Dictionary<string, uint> { { "opponentName", 0xA3A0A48B }, { "gymLeaderNo", 2u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym3", new Dictionary<string, uint> { { "opponentName", 0xA3A0A48B }, { "gymLeaderNo", 3u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym4", new Dictionary<string, uint> { { "opponentName", 0xA3A0A48B }, { "gymLeaderNo", 4u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym5", new Dictionary<string, uint> { { "opponentName", 0xA3A0A48B }, { "gymLeaderNo", 5u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym6", new Dictionary<string, uint> { { "opponentName", 0xA3A0A48B }, { "gymLeaderNo", 6u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym7", new Dictionary<string, uint> { { "opponentName", 0xA3A0A48B }, { "gymLeaderNo", 7u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "gym8", new Dictionary<string, uint> { { "opponentName", 0xA3A0A48B }, { "gymLeaderNo", 8u }, { "mapIndex", 0x2Du }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },
            { "elite4_1", new Dictionary<string, uint> { { "opponentName", 0xB3A8AB84 }, { "trainerClass", 0x2Cu }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } }, //{ "mapIndex", 0xF5u }
            { "elite4_2", new Dictionary<string, uint> { { "opponentName", 0xB3A8AB84 }, { "trainerClass", 0x21u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } }, //{ "mapIndex", 0xF6u }
            { "elite4_3", new Dictionary<string, uint> { { "opponentName", 0xB3A8AB84 }, { "trainerClass", 0x2Eu }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } }, //{ "mapIndex", 0xF7u }
            { "elite4_4", new Dictionary<string, uint> { { "opponentName", 0xB3A8AB84 }, { "trainerClass", 0x2Fu }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } }, //{ "mapIndex", 0x71u }
            { "elite4_5", new Dictionary<string, uint> { { "enemyPkmnName", 0xB4ADA495 }, { "mapIndex", 0x78u }, { "enemyPkmn", 0u }, { "stack", 0x03AEu } } },

            { "rival", new Dictionary<string, uint> { { "mapIndex", 0u }, { "partyCount", 1u } } },
            { "enterMtMoon", new Dictionary<string, uint> { { "mapIndex", 0x3Bu }, { "playerPos", 0x1205u } } },
            { "exitMtMoon", new Dictionary<string, uint> { { "mapIndex", 0x0Fu }, { "playerPos", 0x1B03u } } },
            { "exitVictoryRoad", new Dictionary<string, uint> { { "mapIndex", 0x22u }, { "playerPos", 0x0E1Fu } } },
            { "hm02", new Dictionary<string, uint> { { "itemsInBag", 0xFFu }, { "mapIndex", 0xBCu } } }, // dummy values for itemsinbag
            { "flute", new Dictionary<string, uint> { { "itemsInBag", 0xFFu }, { "mapIndex", 0x95u } } }, // dummy values for itemsinbag
            { "hof", new Dictionary<string, uint> { { "mapIndex", 0x76u }, { "hofPlayerShown", 0x3Bu }, { "hofTile", 0x79u }, { "rBGP", 0xFFu } } },
        };
    });
}

init {
    vars.watchers = new MemoryWatcherList();
    vars.splits = new Dictionary<string, Dictionary<string, uint>>();

    if (!vars.TryFindOffsets(game)) {
        throw new Exception("[Autosplitter] Emulated memory not yet initialized.");
    } else {
        refreshRate = 200/3.0;
    }
}

update {
    vars.watchers.UpdateAll(game);
}

start {
    return vars.watchers["cursorIndex"].Current == 0 && (vars.watchers["input"].Current & 0x80) == 0 && vars.watchers["playerID"].Current == 0 && vars.watchers["stack"].Current == 0x59FF;
}

reset {
    bool downBuffer = vars.watchers["cursorIndex"].Current == 0 && (vars.watchers["input"].Current & 0x80) == 1;
    bool notBuffered = vars.watchers["cursorIndex"].Current == 1 && (vars.watchers["input"].Current & 0x01) == 1;
    return (downBuffer || notBuffered) && vars.watchers["playerID"].Current == 0 && vars.watchers["stack"].Current == 0x59FF;
}

split {
    foreach (var _split in vars.splits) {
       if (settings[_split.Key]) {
            var count = 0;
            foreach (var _condition in _split.Value) {
                if (vars.watchers[_condition.Key].Current == _condition.Value) {
                    count++;
                } else if ((_split.Key == "hm02" || _split.Key == "flute") && (_condition.Key == "itemsInBag") && (vars.watchers[_condition.Key].Current != vars.watchers[_condition.Key].Old)) {
                    count++;
                } else if (_split.Key == "hof" && _condition.Key == "rBGP" && vars.watchers[_condition.Key].Old == 0u) {
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