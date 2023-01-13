void Main() {
    startnew(ClearTaskCoro);
    // permissions check
    if (!HasPermissions()) {
        Notify("Unfortunately, you don't have the required permissions to use this plugin.");
        return;
    }

    AddAudiences();
    SetUpTabs();
    DB::Init();
    InitialLoad();
    startnew(RunWatchers);
    startnew(MainCoro);
    RunTest();
}

void RunTest() {
    sleep(5000);
    DB::AddMapFromUID("SjKOXtKUQeIEVmLFwuFT79fGXv3");
    DB::AddMapFromUID("PQQVgEAmoSNqdOZfjSvlG9971Nf");
    DB::AddMapFromUID("GDPdoWoK7p3QHy1skI9r8rYfpvi");
    DB::AddMapFromUID("ztzk73ADUyxmoe3RBKcZXKvcoR7");
    DB::AddMapFromUID("fPFRM776LkYYreosr9SXbHT4cxa");
    DB::AddMapFromUID("CAw3kvJNDIsVI3Hp0us4_bxP_ri");
    DB::AddMapFromUID("o2Gvm4GF_Cqt45diPVMleZWeBS9");
    DB::AddMapFromUID("OjRpnb4JbMeijuGrkuczVRrD0N8");
    DB::AddMapFromUID("3c1uklnfvKP1IG04MtXSc2kBgV6");
    auto rec = GetSurrondingRecords("3c1uklnfvKP1IG04MtXSc2kBgV6", 987654, 0, 0);
    print(Json::Write(rec['tops']));
    auto world = rec['tops'][0]['top'][0];
    print(Json::Write(world));
}

bool HasPermissions() {
    return Permissions::ViewRecords();
}

bool HasOptionalPermissions() {
    return Permissions::PlayLocalMap();
}

void InitialLoad() {
    auto mapUids = DB::GetAllMapUIDs();
    for (uint i = 0; i < mapUids.Length; i++) {
        Map(mapUids[i]);
        // CheckPause('load map uids');
    }
    auto playerIds = DB::GetAllPlayerIDs();
    for (uint i = 0; i < playerIds.Length; i++) {
        Player(playerIds[i]);
        // CheckPause('load players');
    }
    auto watcherIds = DB::GetAllWatcherIDs();
    for (uint i = 0; i < watcherIds.Length; i++) {
        Watcher(watcherIds[i]);

    }
}


void MainCoro() {
    while (true) {
        yield();
        //
    }
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}


/** Render function called every frame intended for `UI`.
*/
void RenderInterface() {
    RenderMapMonitorWindow();
}
