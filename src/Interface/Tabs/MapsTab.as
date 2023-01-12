

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
        ControlButton(Icons::FloppyO + "##main-export", CoroutineFunc(this.OnClickExport));
        ctrlRhsWidth = (UI::GetCursorPos() - curr - UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing)).x;

        // control buttons always end with SameLine so put a dummy here to go to next line.
        UI::Dummy(vec2());
    }

    void DrawMapsTable() {
        uint nCols = 10;
        if (UI::BeginTable("maps table", nCols, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("##play map btns", UI::TableColumnFlags::WidthFixed);
            UI::TableSetupColumn("Name");
            UI::TableSetupColumn("Author");
            UI::TableSetupColumn(Icons::Eye);
            UI::TableSetupColumn("Rank");
            UI::TableSetupColumn("PB");
            UI::TableSetupColumn("WR");
            UI::TableSetupColumn("Update Period");
            UI::TableSetupColumn("Last Updated");
            UI::TableSetupColumn("##maps col btns", UI::TableColumnFlags::WidthFixed);
            UI::TableHeadersRow();

            // for blah
            DrawMapsTableRow();

            UI::EndTable();
        }
    }

    void DrawMapsTableRow() {
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
            // UI::Text("All Records");
            UI::Text("4");

            UI::TableNextColumn();
            UI::Text("6th");

            UI::TableNextColumn();
            UI::Text(Time::Format(123456));

            UI::TableNextColumn();
            UI::Text("-" + Time::Format(2345, true));

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
    }
}
