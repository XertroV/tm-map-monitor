class Tab {
    // bool canCloseTab = false;

    bool tabOpen = true;
    bool canPopOut = false;
    bool windowOpen {
        get { return !tabOpen; }
        set { tabOpen = !value; }
    }

    string tabName;

    Tab(const string &in tabName, bool canPopOut = false) {
        this.tabName = tabName;
        this.canPopOut = false;
    }

    int get_TabFlags() {
        return UI::TabItemFlags::NoCloseWithMiddleMouseButton
            | UI::TabItemFlags::NoReorder
            ;
    }

    int get_WindowFlags() {
        return UI::WindowFlags::AlwaysAutoResize
            | UI::WindowFlags::NoCollapse
            ;
    }

    void DrawTogglePop() {
        if (!canPopOut) return;
        if (UI::Button((tabOpen ? "Pop Out" : "Back to Tab") + "##" + tabName)) {
            tabOpen = !tabOpen;
        }
        UI::SameLine();
        UI::SetCursorPos(UI::GetCursorPos() + vec2(20, 0));
        if (UI::Button("Remove##"+tabName)) {
            mmTabs.RemoveAt(mmTabs.FindByRef(this));
        }
    }

    void DrawTab() {
        if (!tabOpen) return;
        if (UI::BeginTabItem(tabName, TabFlags)) {
            DrawTogglePop();
            DrawInner();
            UI::EndTabItem();
        }
    }

    void DrawInner() {
        UI::Text("Tab Inner: " + tabName);
        UI::Text("Overload `DrawInner()`");
    }

    void DrawWindow() {
        if (!windowOpen) return;
        if (UI::Begin(tabName, windowOpen, WindowFlags)) {
            DrawTogglePop();
            DrawInner();
        }
        UI::End();
    }
}
