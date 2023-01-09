[Setting hidden]
bool WindowOpen = false;

bool ShowAddMapsWindow = false;
bool ShowNotificationsWindow = false;


const string PluginIcon = Icons::Envelope;
const string MenuTitle = "\\$3f3" + PluginIcon + "\\$z " + Meta::ExecutingPlugin().Name;

uint g_NbNotifications = 1;

/** Render function called every frame intended only for menu items in `UI`.
*/
void RenderMenu() {
    string notifs = g_NbNotifications == 0 ? "" : ("\\$f22(" + g_NbNotifications + ")");
    if (UI::MenuItem(MenuTitle, notifs, WindowOpen)) {
        WindowOpen = !WindowOpen;
    }
}

void RenderMainUI() {
    RenderMapMonitorWindow();
    RenderAddMapWindow();
}

void RenderMapMonitorWindow() {
    if (!WindowOpen) return;
    vec2 size = vec2(700, 400);
    vec2 pos = (vec2(Draw::GetWidth(), Draw::GetHeight()) - size) / 2.;
    UI::SetNextWindowSize(int(size.x), int(size.y), UI::Cond::FirstUseEver);
    UI::SetNextWindowPos(int(pos.x), int(pos.y), UI::Cond::FirstUseEver);
    UI::PushStyleColor(UI::Col::FrameBg, vec4(.2, .2, .2, .5));
    if (UI::Begin(MenuTitle, WindowOpen)) {
        UI::BeginTabBar("mm-tabs");
        for (uint i = 0; i < mmTabs.Length; i++) {
            mmTabs[i].DrawTab();
        }
        UI::EndTabBar();
    }
    UI::End();
    UI::PopStyleColor();
}

array<Tab@> mmTabs;

void SetUpTabs() {
    mmTabs.InsertLast(MapsTab());
}



class MapsTab : Tab {
    MapsTab() {
        super("Maps", false);
    }

    void DrawInner() override {
        DrawControlBar();
        UI::Separator();
        DrawMapsTable();
    }

    vec2 get_ButtonIconSize() {
        float s = UI::GetFrameHeight();
        return vec2(s, s);
    }

    float ctrlRhsWidth;
    vec4 ctrlBtnRect;

    void DrawControlBar() {
        float width = UI::GetContentRegionMax().x;

        ControlButton(Icons::Plus + "##main-add", CoroutineFunc(this.OnClickAddMap));
        ctrlBtnRect = UI::GetItemRect();

        ControlButton(Icons::FloppyO + "##main-export", CoroutineFunc(this.OnClickExport));

        // rhs buttons
        UI::SetCursorPos(vec2(width - ctrlRhsWidth, UI::GetCursorPos().y));
        auto curr = UI::GetCursorPos();
        NotificationsCtrlButton();
        ControlButton(Icons::FloppyO + "##main-export", CoroutineFunc(this.OnClickExport));
        ctrlRhsWidth = (UI::GetCursorPos() - curr - UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing)).x;
        // ctrlRhsWidth = UI::GetItemRect().z;

        // control buttons always end with SameLine so put a dummy here to go to next line.
        UI::Dummy(vec2());
    }

    vec4 colNotifBtnBg = vec4(0.641f, 0.121f, 0.121f, 1.f);
    vec4 colNotifBtnBgActive = vec4(0.851f, 0.192f, 0.192f, 1.000f);
    vec4 colNotifBtnBgHovered = vec4(0.981f, 0.269f, 0.269f, 1.000f);

    void NotificationsCtrlButton() {
        auto size = vec2(ctrlBtnRect.z, ctrlBtnRect.w);
        if (g_NbNotifications == 0) {
            ControlButton(Icons::Inbox + "##notifs", OnClickShowNotifications, size);
            return;
        }
        UI::PushStyleColor(UI::Col::Button, colNotifBtnBg);
        UI::PushStyleColor(UI::Col::ButtonActive, colNotifBtnBgActive);
        UI::PushStyleColor(UI::Col::ButtonHovered, colNotifBtnBgHovered);
        ControlButton(tostring(g_NbNotifications) + "##notifs", OnClickShowNotifications, size);
        UI::PopStyleColor(3);
    }

    bool ControlButton(const string &in label, CoroutineFunc@ onClick, vec2 size = vec2()) {
        bool ret = UI::Button(label, size);
        if (ret) onClick();
        UI::SameLine();
        return ret;
    }

    void DrawMapsTable() {
        uint nCols = 10;
        if (UI::BeginTable("maps table", nCols, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("##play map btns", UI::TableColumnFlags::WidthFixed);
            UI::TableSetupColumn("Name");
            UI::TableSetupColumn("Author");
            UI::TableSetupColumn("Monitor"); // my record, all records
            UI::TableSetupColumn("PB");
            UI::TableSetupColumn("WR");
            UI::TableSetupColumn("Your Rank");
            UI::TableSetupColumn("Update Period");
            UI::TableSetupColumn("Last Updated");
            UI::TableSetupColumn("##maps col btns", UI::TableColumnFlags::WidthFixed);
            UI::TableHeadersRow();

            UI::TableNextRow();
            UI::TableNextColumn();
            if (UI::Button(Icons::FighterJet)) {

            }

            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text("\\$7f8Definitely a map!");

            UI::TableNextColumn();
            UI::Text("XertroV");
            UI::TableNextColumn();
            UI::Text("All Records");

            UI::TableNextColumn();
            UI::Text(Time::Format(123456));

            UI::TableNextColumn();
            UI::Text("-" + Time::Format(2345, true));

            UI::TableNextColumn();
            UI::Text("6th");

            UI::TableNextColumn();
            UI::Text("8 hrs");

            UI::TableNextColumn();
            UI::Text(GetHumanTimeSince(1673242726));

            UI::TableNextColumn();
            if (UI::Button(Icons::Refresh)) {}
            UI::SameLine();
            if (UI::Button(Icons::Pencil)) {}
            UI::SameLine();
            if (UI::Button(Icons::TrashO)) {
                // todo
            }

            UI::EndTable();
        }

    }






    void OnClickAddMap() {
        ShowAddMapsWindow = true;
    }

    void OnClickExport() {
        auto folder = IO::FromStorageFolder("exports/" + Time::FormatString("%Y-%m-%d %H-%M-%S"));
        IO::CreateFolder(folder, true);

        OpenExplorerPath(folder);
    }
}

string m_addMapUid;
void RenderAddMapWindow() {
    if (!ShowAddMapsWindow) return;
    UI::SetNextWindowSize(400, 400, UI::Cond::FirstUseEver);
    if (UI::Begin("Add Map", ShowAddMapsWindow)) {
        UI::AlignTextToFramePadding();
        UI::Text("Search for map:");
        m_addMapUid = UI::InputText("Map UID", m_addMapUid);
    }
    UI::End();
}






void OnClickShowNotifications() {
    ShowNotificationsWindow = true;
}
