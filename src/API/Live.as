
/* example ret val:
        RetVal = {"monthList": MonthObj[], "itemCount": 23, "nextRequestTimestamp": 1654020000, "relativeNextRequest": 22548}
        MonthObj = {"year": 2022, "month": 5, "lastDay": 31, "days": DayObj[], "media": {...}}
        DayObj = {"campaignId": 3132, "mapUid": "fJlplQyZV3hcuD7T1gPPTXX7esd", "day": 4, "monthDay": 31, "seasonUid": "aad0f073-c9e0-45da-8a70-c06cf99b3023", "leaderboardGroup": null, "startTimestamp": 1596210000, "endTimestamp": 1596300000, "relativeStart": -57779100, "relativeEnd": -57692700}
    as of 2022-05-31 there are 23 items, so limit=100 will give you all data till 2029.
*/
Json::Value@ GetTotdByMonth(uint length = 100, uint offset = 0) {
    return CallLiveApiPath("/api/token/campaign/month?" + LengthAndOffset(length, offset));
}

/** https://webservices.openplanet.dev/live/clubs/clubs-mine
    */
Json::Value@ GetMyClubs(uint length = 100, uint offset = 0) {
    return CallLiveApiPath("/api/token/club/mine?" + LengthAndOffset(length, offset));
}

// https://webservices.openplanet.dev/live/clubs/members
Json::Value@ GetClubMembers(uint clubId, uint length = 100, uint offset = 0) {
    return CallLiveApiPath("/api/token/club/" + clubId + "/member?" + LengthAndOffset(length, offset));
}

// https://webservices.openplanet.dev/live/maps/uploaded
Json::Value@ GetYourUploadedMaps(uint length = 100, uint offset = 0) {
    return CallLiveApiPath("/api/token/map?" + LengthAndOffset(length, offset));
}

// https://webservices.openplanet.dev/live/leaderboards/surround
Json::Value@ GetSurrondingRecords(const string &in mapUid, uint score) {
    return GetSurrondingRecords("Personal_Best", mapUid, score);
}

// https://webservices.openplanet.dev/live/leaderboards/surround
Json::Value@ GetSurrondingRecords(const string &in groupId, const string &in mapUid, uint score) {
    return CallLiveApiPath("/api/token/leaderboard/group/" + groupId + "/map/" + mapUid + "/surround/1/1?onlyWorld=true&score=" + score);
}

/**
  https://webservices.openplanet.dev/live/leaderboards/top
  This endpoint only allows you to read a leaderboard's first 10,000 records. The rest of the leaderboard is not available at this level of detail.
  onlyWorld=true
  */
Json::Value@ GetRecords(const string &in mapUid, uint length = 100, uint offset = 0) {
    return GetRecords("Personal_Best", mapUid, length, offset);
}

/**
  https://webservices.openplanet.dev/live/leaderboards/top
  This endpoint only allows you to read a leaderboard's first 10,000 records. The rest of the leaderboard is not available at this level of detail.
  onlyWorld=true
  */
Json::Value@ GetRecords(const string &in groupId, const string &in mapUid, uint length = 100, uint offset = 0) {
    return CallLiveApiPath("/api/token/leaderboard/group/" + groupId + "/map/" + mapUid + "/top?onlyWorld=true&" + LengthAndOffset(length, offset));
}
