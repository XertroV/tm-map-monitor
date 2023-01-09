const string GetHumanTimeSince(uint stamp) {
    auto nSecs = Time::Stamp - stamp;
    auto absNSecs = Math::Abs(nSecs);
    string units;
    float divBy;
    if (absNSecs < 60) {units = " s"; divBy = 1;}
    else if (absNSecs < 3600) {units = " min"; divBy = 60;}
    else if (absNSecs < 86400*2) {units = " hrs"; divBy = 3600;}
    else {units = " days"; divBy = 86400;}
    return Text::Format(absNSecs >= 86400*2 ? "%.1f" : "%.0f", float(nSecs) / divBy) + units;
}
