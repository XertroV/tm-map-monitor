void Main() {
    startnew(ClearTaskCoro);
    if (!HasPermissions()) {
        Notify("Unfortunately, you don't have the required permissions to use this plugin.");
        return;
    }
    // permissions check
    AddAudiences();
    SetUpTabs();
    DB::Init();
    InitialLoad();
    startnew(MainCoro);
}

bool HasPermissions() {
    return Permissions::ViewRecords();
}

bool HasOptionalPermissions() {
    return Permissions::PlayLocalMap();
}


namespace State {
    Map@[] maps;
}


void InitialLoad() {
    auto mapUids = DB::GetAllMapUIDs();
    for (uint i = 0; i < mapUids.Length; i++) {
        State::maps.InsertLast(Map(mapUids[i]));
        CheckPause('load map uids');
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
