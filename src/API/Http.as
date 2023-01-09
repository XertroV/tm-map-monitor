void AddAudiences() {
    NadeoServices::AddAudience("NadeoClubServices");
    NadeoServices::AddAudience("NadeoLiveServices");
}

Json::Value@ FetchLiveEndpoint(const string &in route) {
    trace("[FetchLiveEndpoint] Requesting: " + route);
    auto req = NadeoServices::Get("NadeoLiveServices", route);
    req.Start();
    while(!req.Finished()) { yield(); }
    return Json::Parse(req.String());
}

Json::Value@ FetchClubEndpoint(const string &in route) {
    trace("[FetchClubEndpoint] Requesting: " + route);
    auto req = NadeoServices::Get("NadeoClubServices", route);
    req.Start();
    while(!req.Finished()) { yield(); }
    return Json::Parse(req.String());
}

Json::Value@ CallLiveApiPath(const string &in path) {
    AssertGoodPath(path);
    return FetchLiveEndpoint(NadeoServices::BaseURL() + path);
}

Json::Value@ CallCompApiPath(const string &in path) {
    AssertGoodPath(path);
    return FetchClubEndpoint(NadeoServices::BaseURLCompetition() + path);
}

Json::Value@ CallClubApiPath(const string &in path) {
    AssertGoodPath(path);
    return FetchClubEndpoint(NadeoServices::BaseURLClub() + path);
}

// Ensure we aren't calling a bad path
void AssertGoodPath(string &in path) {
    if (path.Length <= 0 || !path.StartsWith("/")) {
        throw("API Paths should start with '/'!");
    }
}

// Length and offset get params helper
const string LengthAndOffset(uint length, uint offset) {
    return "length=" + length + "&offset=" + offset;
}
