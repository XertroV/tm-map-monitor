class MapNbPlayersRow {
    string _table_name = "map_nb_players";

    int id = -1;
    string id_str;
    string map_uid;
    int nb_players;
    int last_highest_score;
    int created_ts;

    MapNbPlayersRow(int id) {
        this.id = id;
        id_str = tostring(id);
        RefreshFromDB();
    }

    MapNbPlayersRow(const string &in map_uid, int nb_players, int last_highest_score) {
        created_ts = Time::Stamp;
        auto s = DB::db.Prepare("INSERT INTO map_nb_players(map_uid, nb_players, last_highest_score, created_ts) VALUES (?, ?, ?, ?) RETURNING id;");
        s.Bind(1, map_uid);
        s.Bind(2, nb_players);
        s.Bind(3, last_highest_score);
        s.Bind(4, created_ts);
        s.NextRow();
        id = s.GetColumnInt('id');
        id_str = tostring(id);
        RefreshFromDB();
    }

    void RefreshFromDB() {
        auto s = DB::Prepare("SELECT * FROM map_nb_players WHERE id = ? LIMIT 1;");
        s.Bind(1, id);
        // no nextrow means either the constraint failed on insert or something else whent wrong
        if (!s.NextRow()) throw("cannot map_nb_players.refresh from db with id=" + id + ": no next row.");
        map_uid = s.GetColumnString('map_uid');
        nb_players = s.GetColumnInt('nb_players');
        last_highest_score = s.GetColumnInt('last_highest_score');
        created_ts = s.GetColumnInt('created_ts');
    }
}
