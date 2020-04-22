state("bgb") {}
state("bgb64") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("gambatte_speedrun") {}
state("emuhawk") {}

startup {
    //-------------------------------------------------------------//
    settings.Add("entrances", true, "Dungeon Entrance Splits");
    settings.Add("essences", true, "Dungeon End Splits (Essences)");
    settings.Add("boss", true, "Boss Splits");
    settings.Add("items", true, "Item Splits");

    settings.CurrentDefaultParent = "entrances";
    settings.Add("d1Enter", true, "Gnarled Root Dungeon (D1)");
    settings.Add("d2Enter", true, "Snake's Remains (D2)");
    settings.Add("d3Enter", true, "Poison Moth Lair (D3)");
    settings.Add("d4Enter", true, "Dancing Dragon Dungeon (D4)");
    settings.Add("d5Enter", true, "Unicorn's Cave (D5)");
    settings.Add("d6Enter", true, "Ancient Ruins (D6)");
    settings.Add("d7Enter", true, "Explorer's Crypt (D7)");
    settings.Add("d8Enter", true, "Sword & Shield Maze (D8)");
    settings.Add("northernPeakEnter", true, "Northern Peak");

    settings.CurrentDefaultParent = "essences";
    settings.Add("d1Ess", true, "Fertile Soil (D1)");
    settings.Add("d2Ess", true, "Gift of Time (D2)");
    settings.Add("d3Ess", true, "Bright Sun (D3)");
    settings.Add("d4Ess", true, "Soothing Rain (D4)");
    settings.Add("d5Ess", true, "Nurturing Warmth (D5)");
    settings.Add("d6Ess", true, "Blowing Wind (D6)");
    settings.Add("d7Ess", true, "Seed of Life (D7)");
    settings.Add("d8Ess", true, "Changing Seasons (D8)");

    settings.CurrentDefaultParent = "boss";
    settings.Add("onoxEnter", false, "Enter Onox Fight");
    settings.Add("onox", true, "Defeat Onox");
    
    settings.CurrentDefaultParent = "items";
    settings.Add("l1Sword", true, "Sword (L1)");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    vars.timer_OnStart = (EventHandler)((s, e) => {
        vars.splits = vars.GetSplitList();
    });
    timer.OnStart += vars.timer_OnStart;

    vars.TryFindOffsets = (Func<Process, int, long, bool>)((proc, memorySize, baseAddress) => {
        long wramOffset = 0;
        string state = proc.ProcessName.ToLower();
        if (state.Contains("gambatte")) {
            IntPtr scanOffset = vars.SigScan(proc, 0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");
            wramOffset = (long)scanOffset - 0x10;
        } else if (state == "emuhawk") {
            IntPtr scanOffset = vars.SigScan(proc, 0, "05 00 00 00 ?? 00 00 00 00 ?? ?? 00 ?? 40 ?? 00 00 ?? ?? 00 00 00 00 00 ?? 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? 00 ?? 00 00 00 00 00 ?? 00 ?? 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F8 00 00 00");
            wramOffset = (long)scanOffset - 0x40;
        } else if (state == "bgb") {
            IntPtr scanOffset = vars.SigScan(proc, 12, "6D 61 69 6E 6C 6F 6F 70 83 C4 F4 A1 ?? ?? ?? ??");
            wramOffset = new DeepPointer(scanOffset, 0, 0, 0x34).Deref<int>(proc) + 0x108;
        } else if (state == "bgb64") {
            IntPtr scanOffset = vars.SigScan(proc, 20, "48 83 EC 28 48 8B 05 ?? ?? ?? ?? 48 83 38 00 74 1A 48 8B 05 ?? ?? ?? ?? 48 8B 00 80 B8 ?? ?? ?? ?? 00 74 07");
            IntPtr baseOffset = scanOffset + proc.ReadValue<int>(scanOffset) + 4;
            wramOffset = new DeepPointer(baseOffset, 0, 0x44).Deref<int>(proc) + 0x190;
        }

        if (wramOffset > 0) {
            vars.watchers = vars.GetWatcherList((int)(wramOffset - baseAddress));
            print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));
            
            return true;
        }

        return false;
    });

    vars.SigScan = (Func<Process, int, string, IntPtr>)((proc, offset, signature) => {
        var target = new SigScanTarget(offset, signature);
        IntPtr result = IntPtr.Zero;
        foreach (var page in proc.MemoryPages(true)) {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
            if ((result = scanner.Scan(target)) != IntPtr.Zero) {
                break;
            }
        }

        return result;
    });

    vars.GetWatcherList = (Func<int, MemoryWatcherList>)((wramOffset) => {
        return new MemoryWatcherList {
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x91C)) { Name = "d1Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x939)) { Name = "d2Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x94B)) { Name = "d3Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x981)) { Name = "d4Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x9A7)) { Name = "d5Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x9BA)) { Name = "d6Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA5B)) { Name = "d7Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA87)) { Name = "d8Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA97)) { Name = "northernPeakEnter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA91)) { Name = "onoxEnter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x913)) { Name = "d1Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x92C)) { Name = "d2Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x940)) { Name = "d3Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x960)) { Name = "d4Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x988)) { Name = "d5Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x898)) { Name = "d6Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA4F)) { Name = "d7Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA5F)) { Name = "d8Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x11A9)) { Name = "onoxHP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x6AC)) { Name = "sword" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xB00)) { Name = "fileSelect1" },
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0xBB3)) { Name = "fileSelect2" },
            // new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1EFF)) { Name = "resetCheck" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, int>>>)(() => {
        return new Dictionary<string, Dictionary<string, int>> {
            { "d1Enter", new Dictionary<string, int> { {"d1Enter", 0x10} } },
            { "d2Enter", new Dictionary<string, int> { {"d2Enter", 0x10} } },
            { "d3Enter", new Dictionary<string, int> { {"d3Enter", 0x10} } },
            { "d4Enter", new Dictionary<string, int> { {"d4Enter", 0x10} } },
            { "d5Enter", new Dictionary<string, int> { {"d5Enter", 0x10} } },
            { "d6Enter", new Dictionary<string, int> { {"d6Enter", 0x10} } },
            { "d7Enter", new Dictionary<string, int> { {"d7Enter", 0x10} } },
            { "d8Enter", new Dictionary<string, int> { {"d8Enter", 0x10} } },
            { "northernPeakEnter", new Dictionary<string, int> { {"northernPeakEnter", 0x10} } },
            { "onoxEnter", new Dictionary<string, int> { {"onoxEnter", 0x10} } },
            { "d1Ess", new Dictionary<string, int> { {"d1Ess", 0x30} } },
            { "d2Ess", new Dictionary<string, int> { {"d2Ess", 0x30} } },
            { "d3Ess", new Dictionary<string, int> { {"d3Ess", 0x30} } },
            { "d4Ess", new Dictionary<string, int> { {"d4Ess", 0x30} } },
            { "d5Ess", new Dictionary<string, int> { {"d5Ess", 0x30} } },
            { "d6Ess", new Dictionary<string, int> { {"d6Ess", 0x30} } },
            { "d7Ess", new Dictionary<string, int> { {"d7Ess", 0x30} } },
            { "d8Ess", new Dictionary<string, int> { {"d8Ess", 0x30} } },
            { "onox", new Dictionary<string, int> { {"onoxHP", 0x01}, {"onoxEnter", 0x10} } },
            { "l1Sword", new Dictionary<string, int> { {"sword", 0x01} } },
        };
    });
}

init {
    vars.watchers = new MemoryWatcherList();
    vars.splits = new Dictionary<string, Dictionary<string, int>>();

    if (!vars.TryFindOffsets(game, modules.First().ModuleMemorySize, (long)modules.First().BaseAddress)) {
        throw new Exception("[Autosplitter] Emulated memory not yet initialized.");
    } else {
        refreshRate = 200/3.0;
    }
}

update {
    vars.watchers.UpdateAll(game);
}

start {
    return vars.watchers["fileSelect1"].Current == 0x23 && vars.watchers["fileSelect2"].Current == 0x0301;
}

reset {
    //return vars.watchers["resetCheck"].Current > 0;
}

split {
    //prevent splitting on the file select screen
    var fs = vars.watchers["fileSelect1"].Current;
    if (fs == 0x17 || fs == 0x23) {
        return false;
    }

    foreach (var _split in vars.splits) {
        if (settings[_split.Key]) {
            var count = 0;
            foreach (var _condition in _split.Value) {
                if (vars.watchers[_condition.Key].Current == _condition.Value) {
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