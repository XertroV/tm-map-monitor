namespace DB {
    class TableSpec {
        string name;
        int expectedVersion;
        string[] migrations;
    }

    TableSpec@ migrationsTable = MigrationsTable();
    TableSpec@[] tableSpecs = {migrationsTable};

    void LoadTableSpecs() {
        if (tableSpecs.Length > 1) return;
        tableSpecs.InsertLast(MapsTable());
        tableSpecs.InsertLast(NotificationsTable());
        tableSpecs.InsertLast(MapRecordFiltersTable());
    }


    class MigrationsTable : TableSpec {
        MigrationsTable() {
            name = "migrations";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }
        void InsertMigrations() {
            migrations.InsertLast("""
                CREATE TABLE IF NOT EXISTS "migrations" (
                    "id"	INTEGER,
                    "name"	VARCHAR(64) NOT NULL UNIQUE,
                    "version"	INTEGER NOT NULL,
                    "created_ts"	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    "updated_ts"	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    PRIMARY KEY("id" AUTOINCREMENT)
                );
                CREATE INDEX ix_name ON migrations(name);
            """);
        }
    }


    class MapsTable : TableSpec {
        MapsTable() {
            name = "maps";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }

        void InsertMigrations() {
            migrations.InsertLast("""
                CREATE TABLE maps (
                    uid VARCHAR(32) PRIMARY KEY,
                    name TEXT NOT NULL,
                    author TEXT NOT NULL,
                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                );
            """);
            migrations.InsertLast("CREATE INDEX ix_uid ON maps(uid);");
            migrations.InsertLast("ALTER TABLE maps ADD COLUMN is_mine BOOLEAN NOT NULL;");
            migrations.InsertLast("ALTER TABLE maps ADD COLUMN wait_seconds INTEGER NOT NULL DEFAULT 28800;\n"
                                  "ALTER TABLE maps ADD COLUMN last_checked INTEGER NOT NULL DEFAULT 0;\n"
                                  "CREATE INDEX ix_last_check ON maps(last_checked);\n");
        }
    }

    class NotificationsTable : TableSpec {
        NotificationsTable() {
            name = "notifications";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }

        void InsertMigrations() {
            migrations.InsertLast("""
                CREATE TABLE notifications (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    uid VARCHAR(32) NOT NULL,
                    msg TEXT NOT NULL,
                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY("uid") REFERENCES maps(uid)
                );
            """);
        }
    }

    class MapRecordFiltersTable : TableSpec {
        MapRecordFiltersTable() {
            name = "record_filters";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }

        void InsertMigrations() {
            string createTable = """
                CREATE TABLE __TABLE_NAME__ (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    uid VARCHAR(32) NOT NULL,
                    mode INTEGER NOT NULL CHECK(mode >= 0 AND mode <= 2), -- 0: all, 1: local player, 2: other player
                    player_name TEXT,


                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY("uid") REFERENCES maps(uid)
                );
                CREATE INDEX ix_mode ON __TABLE_NAME__(mode);
            """;
            migrations.InsertLast(createTable.Replace("__TABLE_NAME__", name));
        }
    }
}
