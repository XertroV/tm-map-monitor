class MapTimeRow {
    int id;
    string map_uid;
    int batch_number;
    int rank;
    int time;
    string player_id;
    int created_ts;

    string _rankStr;
    const string RankStr() {
        if (_rankStr.Length == 0) {
            // todo, format properly
            _rankStr = FormatRank(rank);
        }
        return _rankStr;
    }

    string _timeStr;
    const string TimeStr() {
        if (_timeStr.Length == 0) {
            // todo, format properly
            _timeStr = Time::Format(time);
        }
        return _timeStr;
    }
}

array<string> suffixes = {"th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th"};

const string FormatRank(int rank) {
    int test = ((rank % 100) - 10);
    if (test > 0 && test < 4) return tostring(rank) + "th";
    return tostring(rank) + suffixes[rank % 10];
}
