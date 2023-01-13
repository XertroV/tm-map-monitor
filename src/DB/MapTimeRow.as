class MapTimeRow {
    int id;
    string id_str;
    string map_uid;
    int batch_number;
    int rank;
    int time;
    string player_id;
    string zone_id;
    int created_ts;

    MapTimeRow(int id) {
        this.id = id;
        id_str = tostring(id);
        RefreshFromDB();
    }

    MapTimeRow(const string &in map_uid, int batch_number, int rank, int time, const string &in player_id, const string &in zone_id) {
        created_ts = Time::Stamp;
        auto s = DB::Prepare("INSERT INTO map_times(map_uid, batch_number, rank, time, player_id, zone_id, created_ts) VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING id;");
        s.Bind(1, map_uid);
        s.Bind(2, batch_number);
        s.Bind(3, rank);
        s.Bind(4, time);
        s.Bind(5, player_id);
        s.Bind(6, zone_id);
        s.Bind(7, created_ts);
        if (!s.NextRow()) throw('insert map time row failed');
        this.id = s.GetColumnInt('id');
        id_str = tostring(id);
        RefreshFromDB();
    }

    void RefreshFromDB() {
        auto s = DB::Prepare("SELECT * FROM map_times WHERE id = ? LIMIT 1;");
        s.Bind(1, id);
        if (!s.NextRow()) throw('map times row cannot RefreshFromDB -- no next row');
        map_uid = s.GetColumnString('map_uid');
        player_id = s.GetColumnString('player_id');
        zone_id = s.GetColumnString('zone_id');
        batch_number = s.GetColumnInt('batch_number');
        rank = s.GetColumnInt('rank');
        time = s.GetColumnInt('time');
        created_ts = s.GetColumnInt('created_ts');
    }

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
