state("GSR") { }
state("GSE") { }
state("gambatte_speedrun") { }

startup {
    //-------------------------------------------------------------//
    settings.Add("anypercent_group", true, "Club Members, Masters, & Pokémon Dome");
    settings.SetToolTip("anypercent_group", "All opponents for the Any% category.");
    settings.Add("club_members_anyp", false, "Club Members (Any%)", "anypercent_group");
    settings.SetToolTip("club_members_anyp", "All non-Master opponents required in the Any% category before the Pokémon Dome.");
        //technically, not "All opponents" yet. Need to figure out how to handle the early Ronalds (and if you win OR lose).
            //for now, you'd have to manually split for the Ronald duel after collecting 2 and 5 master medals
        //also, setting the initial value for this parent group to be false, for those who don't include the members in their splits
    settings.CurrentDefaultParent = "club_members_anyp";
        //the club members are organized in order of their ID values. it's more obvious below
	settings.Add("chris", true, "Chris");
	settings.Add("michael", true, "Michael");
	settings.Add("jessica", true, "Jessica");
	settings.Add("sara", true, "Sara");
	settings.Add("amanda", true, "Amanda");
	settings.Add("joshua", true, "Joshua");
	settings.Add("jennifer", true, "Jennifer");
	settings.Add("nicholas", true, "Nicholas");
	settings.Add("brandon", true, "Brandon");
	settings.Add("brittany", true, "Brittany");
	settings.Add("kristin", true, "Kristin");
	settings.Add("heather", true, "Heather");
	settings.Add("joseph", true, "Joseph");
        //left the [club/grand] masters/ronald in the order Hwangbro had but made a parent group for them
    settings.CurrentDefaultParent = "anypercent_group";
    settings.Add("isaac", true, "Isaac");
    settings.Add("nikki", true, "Nikki");
    settings.Add("amy", true, "Amy");
    settings.Add("gene", true, "Gene");
    settings.Add("ken", true, "Ken");
    settings.Add("murray", true, "Murray");
    settings.Add("rick", true, "Rick");
    settings.Add("mitch", true, "Mitch");
    settings.Add("courtney", true, "Courtney");
    settings.Add("steve", true, "Steve");
    settings.Add("jack", true, "Jack");
    settings.Add("rod", true, "Rod");
    settings.Add("ronald", false, "Ronald");
    settings.Add("end", true, "End");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("GBC");

    vars.Helper.Load = (Func<dynamic, bool>)(emu =>
    {
        emu.Make<byte>("wWhoseTurn", 0x0C05);
        emu.Make<byte>("wDuelFinished", 0x0C07);
        emu.Make<ushort>("wOpponentName", 0x0C16);
        emu.Make<byte>("wCurMenuItem", 0x0D10);
        emu.Make<byte>("wMenuCursorXOffset", 0x0D11);
        emu.Make<byte>("wGameEvent", 0x10B5);
        emu.Make<byte>("wTempMap", 0x10BB);
        emu.Make<byte>("wCurSongID", 0x1D80);
        emu.Make<ushort>("wScriptPointer", 0x1413);

        emu.Make<byte>("hKeysPressed", 0xFF91);

        return true;
    });

    vars.Current = (Func<string, uint, bool>)((name, value) => 
    {
        return vars.Helper[name].Current == value;
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
    {
        bool battleOver = vars.Current("wDuelFinished", 1) && vars.Current("wWhoseTurn", 0xC2) && vars.Current("wGameEvent", 0);

        return new Dictionary<string, bool> {
            {"chris", vars.Current("wOpponentName", 0xB403) && battleOver},
			{"michael", vars.Current("wOpponentName", 0xB503) && battleOver},
			{"jessica", vars.Current("wOpponentName", 0xB603) && battleOver},
			{"sara", vars.Current("wOpponentName", 0xBC03) && battleOver},
			{"amanda", vars.Current("wOpponentName", 0xBD03) && battleOver},
			{"joshua", vars.Current("wOpponentName", 0xBE03) && battleOver},
			{"jennifer", vars.Current("wOpponentName", 0xC003) && battleOver},
			{"nicholas", vars.Current("wOpponentName", 0xC103) && battleOver},
			{"brandon", vars.Current("wOpponentName", 0xC203) && battleOver},
			{"brittany", vars.Current("wOpponentName", 0xC403) && battleOver},
			{"kristin", vars.Current("wOpponentName", 0xC503) && battleOver},
			{"heather", vars.Current("wOpponentName", 0xC603) && battleOver},
			{"joseph", vars.Current("wOpponentName", 0xCC03) && battleOver},
			    // for now, leaving the club members on top, then the club masters, grand masters, ronald at the end
            {"isaac", vars.Current("wOpponentName", 0xC303) && battleOver},
            {"nikki", vars.Current("wOpponentName", 0xC703) && battleOver},
            {"amy", vars.Current("wOpponentName", 0xBF03) && battleOver},
            {"gene", vars.Current("wOpponentName", 0xBB03) && battleOver},
            {"ken", vars.Current("wOpponentName", 0xD303) && battleOver},
            {"murray", vars.Current("wOpponentName", 0xCB03) && battleOver},
            {"rick", vars.Current("wOpponentName", 0xCF03) && battleOver},
            {"mitch", vars.Current("wOpponentName", 0xB703) && battleOver},
            {"courtney", vars.Current("wOpponentName", 0xD403) && battleOver},
            {"steve", vars.Current("wOpponentName", 0xD503) && battleOver},
            {"jack", vars.Current("wOpponentName", 0xD603) && battleOver},
            {"rod", vars.Current("wOpponentName", 0xD703) && battleOver},
            {"ronald", vars.Current("wOpponentName", 0xAD03) && battleOver && vars.Current("wTempMap", 0x20)},
            {"end", vars.Current("wTempMap", 1) && vars.Current("wScriptPointer", 0x0C7C)},
        };
    });
}

init {
    vars.pastSplits = new HashSet<string>();
    refreshRate = 200 / 3.0;
}

update {
    if(timer.CurrentPhase == TimerPhase.NotRunning && vars.pastSplits.Count > 0)
    {
        vars.pastSplits.Clear();
    }
}

start {
    return current.wMenuCursorXOffset == 1 && (current.hKeysPressed & 0x1) == 1 && old.wCurSongID == 0x86 && current.wCurMenuItem == 0x1;
}

split {
    var splits = vars.GetSplitList();

    foreach(var split in splits)
    {
        if (settings[split.Key] && split.Value && !vars.pastSplits.Contains(split.Key))
        {
            vars.pastSplits.Add(split.Key);
            print("[AutoSplitter] Split: " + split.Key);
            return true;
        }

    }
}

exit {
    refreshRate = 0.5;
}

shutdown {
    timer.OnStart -= vars.timer_OnStart;
}
