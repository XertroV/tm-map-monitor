namespace DB {
    SQLite::Database@ db = null;
    string dbPath = IO::FromStorageFolder("db.sqlite");

    void Init() {
        if (db !is null) return;
        IO::Delete(dbPath);
        yield();
        bool dbAlreadyExists = IO::FileExists(dbPath);
        @db = SQLite::Database(dbPath);
        LoadTableSpecs();
        yield();
        if (!dbAlreadyExists) _InitialCreation();
        yield();
        Migrations::CheckMigrations();
    }

    void _InitialCreation() {
        db.Execute(migrationsTable.migrations[0]);
        trace('Created migrations table.');
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
        auto s = db.Prepare("SELECT * FROM maps WHERE uid = ? LIMIT 1");
        s.Bind(1, uid);
        return s;
    }
}
