class Map {
    string uid;
    string name;
    string author;
    uint created_ts;
    uint updated_ts;


    Map(const string &in uid) {
        this.uid = uid;
        RefreshFromDB();
    }

    Map(SQLite::Statement@ statement) {
        // todo
    }



    void RefreshFromDB() {
        SQLite::Statement@ s = DB::GetMapWithRecordFilters(uid);
        if (s is null || !s.NextRow()) throw("Cannot create a map object from 0 rows!");

        while (s.NextRow()) {
            // todo
        }
    }
}
