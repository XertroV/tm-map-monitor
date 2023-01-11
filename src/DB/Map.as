class Map {
    int id;
    string uid;
    string name;
    string author;
    int created_ts;
    int updated_ts;
    bool is_mine;

    Map(const string &in uid) {
        this.uid = uid;
        RefreshFromDB();
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
        updated_ts = Time::Now;
        auto s = DB::db.Prepare("UPDATE maps SET name = ?, author = ?, updated_ts = ?, is_mine = ? WHERE uid = ?;");
        s.Bind(1, name);
        s.Bind(2, author);
        s.Bind(3, updated_ts);
        s.Bind(4, is_mine ? 1 : 0);
        s.Bind(5, uid);
        s.Execute();
    }
}
