namespace DB {
    namespace Migrations {
        void CheckMigrations() {
            for (uint i = 0; i < tableSpecs.Length; i++) {
                CreateOrMigrate(tableSpecs[i]);
            }
        }

        void CreateOrMigrate(TableSpec@ table) {
            auto currVer = Migrations::GetTableVersion(table.name);
            if (currVer >= table.expectedVersion) {
                trace('No migrations for ' + table.name);
                return;
            }
            for (int i = currVer; i < table.expectedVersion; i++) {
                RunMigration(i, table);
                yield();
            }
        }

        void RunMigration(int i, TableSpec@ table) {
            trace("Running migration " + i + " for " + table.name);
            db.Execute(table.migrations[i]);
            Migrations::SetTableVersion(i + 1, table);
            trace("Updated table " + table.name + " to version " + (i + 1));
        }

        int GetTableVersion(const string &in table) {
            auto s = db.Prepare("SELECT (version) FROM migrations WHERE name = ?;");
            s.Bind(1, table);
            if (!s.NextRow()) return 0;
            return s.GetColumnInt('version');
        }

        void SetTableVersion(int ver, TableSpec@ table) {
            SQLite::Statement@ s;
            if (ver == 1) {
                @s = db.Prepare("INSERT INTO migrations (name, version, created_ts, updated_ts) VALUES (?, ?, ?, ?);");
                s.Bind(1, table.name);
                s.Bind(2, ver);
                s.Bind(3, Time::Stamp);
                s.Bind(4, Time::Stamp);
            } else {
                @s = db.Prepare("UPDATE migrations SET version = ?, updated_ts = ? WHERE name = ?;");
                s.Bind(1, ver);
                s.Bind(2, Time::Stamp);
                s.Bind(3, table.name);
            }
            s.Execute();
        }
    }
}
