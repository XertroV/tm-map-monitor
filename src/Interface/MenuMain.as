/** Render function called every frame intended only for menu items in the main menu of the `UI`.
*/
void RenderMenuMain() {
    if (UI::BeginMenu(MenuMain::Label)) {


        UI::EndMenu();
    }
}

namespace MenuMain {
    uint _lastNbNotifs = 0;

    string _lastMenuLabel;

    const string Label {
        get {
            if (g_NbNotifications == _lastNbNotifs && _lastMenuLabel.Length > 0) return _lastMenuLabel;
            _lastNbNotifs = g_NbNotifications;
            if (g_NbNotifications == 0) {
                _lastMenuLabel = MenuTitle;
            } else {
                _lastMenuLabel = "\\$f33" + MenuTitle.SubStr(5) + "   \\$f33(" + g_NbNotifications + ")";
            }
            return _lastMenuLabel;
        }
    }
}
