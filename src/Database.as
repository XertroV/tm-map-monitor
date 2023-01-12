namespace DB {
    SQLite::Database@ db = null;
    string dbPath = IO::FromStorageFolder("db.sqlite");

    void Init() {
        if (db !is null) return;
        IO::Delete(dbPath); yield();
        bool dbAlreadyExists = IO::FileExists(dbPath);
        @db = SQLite::Database(dbPath);
        LoadTableSpecs();
        yield();
        if (!dbAlreadyExists) _InitialCreation();
        yield();
        Migrations::CheckMigrations();
    }

    SQLite::Statement@ Prepare(const string &in query) {
        return db.Prepare(query);
    }

    void _InitialCreation() {
        db.Execute(migrationsTable.migrations[0]);
        trace('Created migrations table.');
    }


    int[]@ GetAllWatcherIDs() {
        int[] ret;
        auto s = db.Prepare("SELECT id FROM watchers ORDER BY id ASC;");
        while (s.NextRow()) {
            ret.InsertLast(s.GetColumnInt('id'));
        }
        return ret;
    }


    string[]@ GetAllMapUIDs() {
        string[] ret;
        auto s = db.Prepare("SELECT uid FROM maps ORDER BY uid ASC;");
        while (s.NextRow()) {
            ret.InsertLast(s.GetColumnString('uid'));
        }
        return ret;
    }

    SQLite::Statement@ GetMap(const string &in uid) {
        auto s = db.Prepare("SELECT * FROM maps WHERE uid = ? LIMIT 1;");
        s.Bind(1, uid);
        return s;
    }

    bool MapExists(const string &in uid) {
        auto s = db.Prepare("SELECT COUNT(uid) as uid_count FROM maps WHERE uid = ?;");
        s.Bind(1, uid);
        if (!s.NextRow()) return false;
        return s.GetColumnInt('uid_count') > 0;
    }

    Map@ AddMapFromUID(const string &in uid) {
        if (State::IsMapKnown(uid)) return State::GetMap(uid);
        // get required map details
        auto mapInfo = GetMapFromUid(uid);
        // add to database
        auto map = Map(uid, ColoredString(mapInfo.Name), mapInfo.AuthorDisplayName, mapInfo.AuthorAccountId == LocalAccountId);
        auto pbWatcher = Watcher(map.uid, WatchSubject::LocalPlayer, LocalAccountId, 28800);
        trace('DB::AddMapFromUID: ' + uid + ' with pb watcher: ' + pbWatcher.id);
        return map;
    }
}
