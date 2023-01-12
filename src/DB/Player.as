class Player {
    int id;
    string wsid;
    string name;
    string club_tag;

    Player(const string &in wsid) {
        this.wsid = wsid;
        RefreshFromDB();
        State::AddPlayer(this);
    }

    Player(const string &in wsid, const string &in name, const string &in club_tag) {
        this.wsid = wsid;
        auto s = DB::Prepare("INSERT INTO players(wsid, name, club_tag, created_ts, updated_ts) VALUES (?, ?, ?, ?, ?) RETURNING id;");
        s.Bind(1, wsid);
        s.Bind(2, name);
        s.Bind(3, club_tag);
        s.Bind(4, Time::Stamp);
        s.Bind(5, Time::Stamp);
        if (!s.NextRow()) throw('player insert failed');
        id = s.GetColumnInt('id');
        RefreshFromDB();
        State::AddPlayer(this);
    }

    void RefreshFromDB() {
        auto s = DB::Prepare("SELECT * FROM players WHERE wsid = ?;");
        s.Bind(1, wsid);
        if (!s.NextRow()) throw("player refresh got no data");
        id = s.GetColumnInt('id');
        name = s.GetColumnString('name');
        club_tag = s.GetColumnString('club_tag');
    }

    void Save() {
        throw('player.save todo');
    }

    string _tagAndName;
    const string DisplayTagAndName {
        get {
            if (_tagAndName.Length == 0) {
                if (club_tag.Length == 0)
                    _tagAndName = name;
                else
                    _tagAndName = '[' + club_tag + '\\$z] ' + name;
            }
            return _tagAndName;
        }
    }
}
