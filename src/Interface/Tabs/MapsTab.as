

class MapsTab : Tab {
    MapsTab() {
        super(Icons::Map + " Maps", false);
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
        NotificationsCtrlButton(vec2(ctrlBtnRect.z, ctrlBtnRect.w));
        ControlButton(Icons::FloppyO + "##main-export2", CoroutineFunc(this.OnClickExport));
        ctrlRhsWidth = (UI::GetCursorPos() - curr - UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing)).x;

        // control buttons always end with SameLine so put a dummy here to go to next line.
        UI::Dummy(vec2());
    }

    void DrawMapsTable() {
        uint nCols = 8;
        if (UI::BeginTable("maps table", nCols, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("##play map btns", UI::TableColumnFlags::WidthFixed);
            UI::TableSetupColumn("Name");
            UI::TableSetupColumn("Author");
            UI::TableSetupColumn(Icons::Eye);
            UI::TableSetupColumn("Rank");
            UI::TableSetupColumn("PB");
            UI::TableSetupColumn("WR");
            // UI::TableSetupColumn("Update Period");
            // UI::TableSetupColumn("Last Updated");
            UI::TableSetupColumn("##maps col btns", UI::TableColumnFlags::WidthFixed);
            UI::TableHeadersRow();

            UI::ListClipper mapClipper(State::maps.Length);
            while (mapClipper.Step()) {
                for (uint i = mapClipper.DisplayStart; i < mapClipper.DisplayEnd; i++) {
                    DrawMapsTableRow(State::maps[i]);
                }
            }

            UI::EndTable();
        }
    }

    void DrawMapsTableRow(Map@ map) {
            UI::TableNextRow();
            UI::TableNextColumn();
            if (UI::Button(Icons::FighterJet)) {
                // todo: play map
            }

            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text(map.name);

            UI::TableNextColumn();
            UI::Text(map.author);
            UI::TableNextColumn();
            UI::Text(tostring(State::NbWatchersFor(map.uid)));
            UI::SameLine();
            if (UI::Button(Icons::Plus + Icons::Eye)) {}

            auto myPb = State::GetMyPb(map.uid);

            UI::TableNextColumn();
            UI::Text(myPb is null ? "?" : myPb.RankStr());

            UI::TableNextColumn();
            UI::Text(myPb is null ? "?" : myPb.TimeStr());

            UI::TableNextColumn();
            UI::Text("-" + Time::Format(2345, true));

            // UI::TableNextColumn();
            // UI::Text("8 hrs");

            // UI::TableNextColumn();
            // UI::Text(GetHumanTimeSince(map.updated_ts));

            UI::TableNextColumn();
            if (UI::Button(Icons::Pencil)) {}
            UI::SameLine();
            if (UI::Button(Icons::TrashO)) {
                // todo
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
