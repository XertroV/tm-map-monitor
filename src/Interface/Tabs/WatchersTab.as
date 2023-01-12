

class WatchersTab : Tab {
    WatchersTab() {
        super(Icons::Eye + " Watchers", false);
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

        ControlButton(Icons::Plus + "##watchers-add", CoroutineFunc(this.OnClickAddWatcher));
        ctrlBtnRect = UI::GetItemRect();

        // ControlButton(Icons::FloppyO + "##watchers-export", CoroutineFunc(this.OnClickExport));

        // rhs buttons
        UI::SetCursorPos(vec2(width - ctrlRhsWidth, UI::GetCursorPos().y));
        auto curr = UI::GetCursorPos();
        NotificationsCtrlButton(vec2(ctrlBtnRect.z, ctrlBtnRect.w));
        // ControlButton(Icons::FloppyO + "##watchers-export2", CoroutineFunc(this.OnClickExport));
        ctrlRhsWidth = (UI::GetCursorPos() - curr - UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing)).x;

        // control buttons always end with SameLine so put a dummy here to go to next line.
        UI::Dummy(vec2());
    }

    void DrawMapsTable() {
        uint nCols = 8;
        if (UI::BeginTable("watchers table", nCols, UI::TableFlags::SizingStretchProp)) {
            // UI::TableSetupColumn("##play map btns", UI::TableColumnFlags::WidthFixed);
            UI::TableSetupColumn("ID");
            UI::TableSetupColumn("Map");
            UI::TableSetupColumn("Subject");
            UI::TableSetupColumn("Player");
            // UI::TableSetupColumn("Rank");
            // UI::TableSetupColumn("PB");
            // UI::TableSetupColumn("WR");
            UI::TableSetupColumn("Update Period");
            UI::TableSetupColumn("Last Updated");
            UI::TableSetupColumn("Next Update");
            UI::TableSetupColumn("##watchers col btns", UI::TableColumnFlags::WidthFixed);
            UI::TableHeadersRow();

            UI::ListClipper watchersClipper(State::watchers.Length);
            while (watchersClipper.Step()) {
                for (uint i = watchersClipper.DisplayStart; i < watchersClipper.DisplayEnd; i++) {
                    DrawWatchersTableRow(State::watchers[i]);
                }
            }

            UI::EndTable();
        }
    }

    void DrawWatchersTableRow(Watcher@ watcher) {
        auto map = State::GetMap(watcher.map_uid);
        auto player = State::GetPlayer(watcher.player_id);

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text(tostring(watcher.id));

        UI::TableNextColumn();
        UI::Text(map.name);
        // if (UI::Button(Icons::FighterJet)) {
        //     // todo: play map
        // }

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::Text(tostring(watcher.subject_type));

        UI::TableNextColumn();
        UI::Text(player is null ? "??" : player.DisplayTagAndName);

        UI::TableNextColumn();
        UI::Text(GetHumanTimePeriod(watcher.update_period));

        UI::TableNextColumn();
        UI::Text(GetHumanTimeSince(watcher.updated_ts));

        UI::TableNextColumn();
        UI::Text(GetHumanTimePeriod(Math::Max(0, watcher.update_after - Time::Stamp)));

        UI::TableNextColumn();
        if (UI::Button(Icons::Pencil)) {}
        UI::SameLine();
        if (UI::Button(Icons::TrashO)) {
            // todo
        }
    }

    void OnClickAddWatcher() {
        // ShowAddMapsWindow = true;
    }
}
