// corresponds to mode
enum WatchSubject {
    NbPlayers = 0,
    TopTimes = 1,
    LocalPlayer = 2,
    AnotherPlayer = 3
}


class Watcher {
    int id = -1;
    string id_str;
    string map_uid;
    WatchSubject subject_type;
    string player_id;
    int update_period;
    int update_after;
    bool disabled;
    int created_ts;
    int updated_ts;
    int run_count = 0;

    Watcher(int id) {
        this.id = id;
        id_str = tostring(id);
        RefreshFromDB();
        State::AddWatcher(this);
    }

    Watcher(const string &in map_uid, WatchSubject subject_type, const string &in player_id, int update_period) {
        disabled = false;
        created_ts = Time::Stamp;
        updated_ts = Time::Stamp;
        auto s = DB::db.Prepare("INSERT INTO watchers(map_uid, subject_type, player_id, update_period, update_after, disabled, created_ts, updated_ts) VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id;");
        s.Bind(1, map_uid);
        s.Bind(2, int(subject_type));
        s.Bind(3, player_id);
        s.Bind(4, update_period);
        s.Bind(5, update_after);
        s.Bind(6, disabled ? 1 : 0);
        s.Bind(7, created_ts);
        s.Bind(8, updated_ts);
        s.NextRow();
        id = s.GetColumnInt('id');
        id_str = tostring(id);
        RefreshFromDB();
        State::AddWatcher(this);
    }

    void RefreshFromDB() {
        auto s = DB::Prepare("SELECT * FROM watchers WHERE id = ? LIMIT 1;");
        s.Bind(1, id);
        // no nextrow means either the constraint failed on insert or something else whent wrong
        if (!s.NextRow()) throw("cannot watcher.refresh from db with id=" + id + ": no next row.");
        map_uid = s.GetColumnString('map_uid');
        subject_type = WatchSubject(s.GetColumnInt('subject_type'));
        player_id = s.GetColumnString('player_id');
        update_period = s.GetColumnInt('update_period');
        update_after = s.GetColumnInt('update_after');
        disabled = s.GetColumnInt('disabled') > 0;
        created_ts = s.GetColumnInt('created_ts');
        updated_ts = s.GetColumnInt('updated_ts');
        run_count = s.GetColumnInt('run_count');
    }

    void Save() {
        update_after = Math::Min(update_after, update_period + updated_ts);
        updated_ts = Time::Stamp;
        auto s = DB::db.Prepare("UPDATE watchers SET update_period = ?, update_after = ?, disabled = ?, updated_ts = ?, run_count = ? WHERE id = ?;");
        s.Bind(1, update_period);
        s.Bind(2, update_after);
        s.Bind(3, disabled ? 1 : 0);
        s.Bind(4, updated_ts);
        s.Bind(5, run_count);
        s.Bind(6, id);
        s.Execute();
    }
}
