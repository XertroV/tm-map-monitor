class Map {
    int id = -1;
    string uid;
    string name;
    string author;
    int created_ts;
    int updated_ts;
    bool is_mine;

    Map(const string &in uid) {
        this.uid = uid;
        RefreshFromDB();
        State::AddMap(this);
    }

    Map(const string &in uid, const string &in name, const string &in author, bool is_mine) {
        this.uid = uid;
        // this.name = name;
        // this.author = author;
        // this.is_mine = is_mine;
        // this.created_ts = Time::Now;
        // this.updated_ts = Time::Now;
        auto s = DB::db.Prepare("INSERT INTO maps(uid, name, author, is_mine, created_ts, updated_ts) values (?, ?, ?, ?, ?, ?) RETURNING uid;");
        s.Bind(1, uid);
        s.Bind(2, name);
        s.Bind(3, author);
        s.Bind(4, is_mine ? 1 : 0);
        s.Bind(5, Time::Stamp);
        s.Bind(6, Time::Stamp);
        if (!s.NextRow()) throw('Map already exists');
        // refresh to get id and other props
        RefreshFromDB();
        State::AddMap(this);
    }

    void RefreshFromDB() {
        SQLite::Statement@ s = DB::GetMap(uid);
        if (s is null || !s.NextRow()) throw("Cannot create a map object from 0 rows!");
        id = s.GetColumnInt('id');
        name = s.GetColumnString('name');
        author = s.GetColumnString('author');
        created_ts = s.GetColumnInt('created_ts');
        updated_ts = s.GetColumnInt('updated_ts');
        is_mine = s.GetColumnInt('is_mine') > 0;
    }

    void Save() {
        updated_ts = Time::Stamp;
        auto s = DB::db.Prepare("UPDATE maps SET name = ?, author = ?, updated_ts = ?, is_mine = ? WHERE uid = ?;");
        s.Bind(1, name);
        s.Bind(2, author);
        s.Bind(3, updated_ts);
        s.Bind(4, is_mine ? 1 : 0);
        s.Bind(5, uid);
        s.Execute();
    }
}
