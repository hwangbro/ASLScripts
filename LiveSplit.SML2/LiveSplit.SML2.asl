state("gambatte") {}
state("gambatte_speedrun") {}

startup {
    //-------------------------------------------------------------//
    settings.Add("intro", true, "Intro");
    settings.Add("tree1", true, "Tree 1");
    settings.Add("tree2", true, "Tree 2");
    settings.Add("tree3", true, "Tree 3");
    settings.Add("tree4", true, "Tree 4 (Boss)");
    settings.Add("bubble", true, "Bubble");
    settings.Add("space1", true, "Space 1");
    settings.Add("space2", true, "Space 2 (Boss)");
    settings.Add("macro1", true, "Macro 1");
    settings.Add("macrob", true, "Macro Bonus");
    settings.Add("macro4", true, "Macro 4 (Boss)");
    settings.Add("pumpkin1", true, "Pumpkin 1");
    settings.Add("pumpkin2", true, "Pumpkin 2");
    settings.Add("pumpkin3", true, "Pumpkin 3");
    settings.Add("pumpkin4", true, "Pumpkin 4 (Boss)");
    settings.Add("turtle1", true, "Turtle 1");
    settings.Add("turtle2", true, "Turtle 2");
    settings.Add("turtle3", true, "Turtle 3 (Boss)");
    settings.Add("mario1", true, "Mario 1");
    settings.Add("mario2", true, "Mario 2");
    settings.Add("mario3", true, "Mario 3");
    settings.Add("mario4", true, "Mario 4 (Boss)");
    settings.Add("castle", true, "Castle (End)");
    //-------------------------------------------------------------//

    refreshRate = 60;

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
            vars.watchers = vars.GetWatcherList((int)(scanOffset - 0x400000), (int)(scanOffset + 0x16CC - 0x400000), ((IntPtr)(scanOffset + 0x147C)));
            print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));

            return true;
        }

        return false;
    });

    vars.GetWatcherList = (Func<int, int, IntPtr, MemoryWatcherList>)((ramOffset, vramOffset, hramOffset) => {
        return new MemoryWatcherList {
            new MemoryWatcher<ushort>(new DeepPointer(ramOffset, 0xA400)) { Name = "musicID" },
            new MemoryWatcher<ushort>(new DeepPointer(ramOffset, 0xA433)) { Name = "sound1ID" },
            new MemoryWatcher<byte>(new DeepPointer(ramOffset, 0xA042)) { Name = "save1LevelCount" },
            new MemoryWatcher<byte>(new DeepPointer(vramOffset, 0x177F)) { Name = "vramLevelIndex" },
            new MemoryWatcher<byte>(new DeepPointer(ramOffset, 0xA269))  { Name = "curLevel" },
            new MemoryWatcher<byte>(new DeepPointer(ramOffset, 0xA100)) { Name = "marioY" },
            new MemoryWatcher<byte>(new DeepPointer(ramOffset, 0xA101)) { Name = "marioX" },
            new MemoryWatcher<byte>(new DeepPointer(ramOffset, 0xAFC5)) { Name = "bossHP" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, uint>>>)(() => {
        return new Dictionary<string, Dictionary<string, uint>> {
            { "intro", new Dictionary<string, uint> { { "curLevel", 0u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "tree1", new Dictionary<string, uint> { { "curLevel", 1u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "tree2", new Dictionary<string, uint> { { "curLevel", 2u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "tree3", new Dictionary<string, uint> { { "curLevel", 3u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "tree4", new Dictionary<string, uint> { { "curLevel", 5u }, { "musicID", 0x7000 }, { "sound1ID", 0x5E03 } } },
            { "bubble", new Dictionary<string, uint> { { "curLevel", 0x11u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "space1", new Dictionary<string, uint> { { "curLevel", 0x12u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "space2", new Dictionary<string, uint> { { "curLevel", 0x13u }, { "musicID", 0x7000 }, { "sound1ID", 0x5E03 } } },
            { "macro1", new Dictionary<string, uint> { { "curLevel", 0x14u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "macrob", new Dictionary<string, uint> { { "curLevel", 0x1Eu }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "macro4", new Dictionary<string, uint> { { "curLevel", 0x17u }, { "musicID", 0x7000 }, { "sound1ID", 0x5E03 } } },
            { "pumpkin1", new Dictionary<string, uint> { { "curLevel", 6u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "pumpkin2", new Dictionary<string, uint> { { "curLevel", 7u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "pumpkin3", new Dictionary<string, uint> { { "curLevel", 8u }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "pumpkin4", new Dictionary<string, uint> { { "curLevel", 9u }, { "musicID", 0x7000 }, { "sound1ID", 0x5E03 } } },
            { "turtle1", new Dictionary<string, uint> { { "curLevel", 0xEu }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "turtle2", new Dictionary<string, uint> { { "curLevel", 0xFu }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "turtle3", new Dictionary<string, uint> { { "curLevel", 0x10u }, { "musicID", 0x7000 }, { "sound1ID", 0x5E03 } } },
            { "mario1", new Dictionary<string, uint> { { "curLevel", 0x1Au }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "mario2", new Dictionary<string, uint> { { "curLevel", 0x1Bu }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "mario3", new Dictionary<string, uint> { { "curLevel", 0x1Cu }, { "musicID", 0x4300 }, { "sound1ID", 0xDC60 } } },
            { "mario4", new Dictionary<string, uint> { { "curLevel", 0x1Du }, { "musicID", 0x7000 }, { "sound1ID", 0x5E03 } } },
            { "castle", new Dictionary<string, uint> { { "curLevel", 0x18u }, { "bossHP", 0u } } },
        };
    });
}

start {
    return (vars.watchers["vramLevelIndex"].Current == 255 && vars.watchers["save1LevelCount"].Current == 0 &&
        vars.watchers["marioX"].Current == 0x20 && vars.watchers["marioY"].Current > 0x70 && vars.watchers["marioY"].Old == 0x70);
}

reset {
    return (vars.watchers["vramLevelIndex"].Current == 255 && vars.watchers["save1LevelCount"].Current == 0 &&
        vars.watchers["save1LevelCount"].Old > 0);
}

init {
    vars.watchers = new MemoryWatcherList();
    vars.splits = new Dictionary<string, Dictionary<string, uint>>();

    if (!vars.TryFindOffsets(game)) {
        throw new Exception("[Autosplitter] Emulated memory not yet initialized.");
    } else {
        refreshRate = 200/3.0;
    }

    vars.finalWario = 0;
}

update {
    vars.watchers.UpdateAll(game);
    if(vars.watchers["curLevel"].Current != 0x18) {
        vars.finalWario = 0;
    }
}

split {
    foreach (var _split in vars.splits) {
       if (settings[_split.Key]) {
            var count = 0;
            foreach (var _condition in _split.Value) {
                if (vars.watchers[_condition.Key].Current == _condition.Value) {
                    if(_condition.Key == "bossHP") {
                        if(vars.watchers["bossHP"].Old == 2) {
                            // only split on final wario, wario has 3 stages
                            if(vars.finalWario < 2) {
                                vars.finalWario++;
                            } else {
                                count++;
                            }
                        } else {
                            continue;
                        }
                    } else {
                        count++;
                    }
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