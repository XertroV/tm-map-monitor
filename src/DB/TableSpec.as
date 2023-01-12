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
        tableSpecs.InsertLast(PlayersTable());
        tableSpecs.InsertLast(WatchRulesTable());
        tableSpecs.InsertLast(MapNbPlayers());
        tableSpecs.InsertLast(MapTimesTable());
        // tableSpecs.InsertLast(MapPlayerRanks());
        // tableSpecs.InsertLast(MapPlayerTimes());
        tableSpecs.InsertLast(NotifyRulesTable());
        tableSpecs.InsertLast(NotificationsTable());
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
                    is_mine INTEGER NOT NULL,
                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                );
                CREATE INDEX ix_maps_uid ON maps(uid);
            """);
        }
    }

    class PlayersTable : TableSpec {
        PlayersTable() {
            name = "players";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }

        void InsertMigrations() {
            migrations.InsertLast("""
                CREATE TABLE players (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    wsid VARCHAR(64),
                    name TEXT NOT NULL,
                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                );
                CREATE INDEX ix_players_wsid ON players(wsid);
            """);
            migrations.InsertLast("ALTER TABLE players ADD COLUMN club_tag TEXT;");
        }
    }

    class WatchRulesTable : TableSpec {
        WatchRulesTable() {
            name = "watchers";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }

        void InsertMigrations() {
            string createTable = """
                CREATE TABLE __TABLE_NAME__ (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    map_uid VARCHAR(32) NOT NULL,

                    subject_type INTEGER NOT NULL CHECK(subject_type >= 0 AND subject_type <= 3), -- 0: nb_players, 1: top times, 2: my rank/time, 3: other players rank/time

                    player_id VARCHAR(64),

                    update_period INTEGER NOT NULL DEFAULT 28800,
                    update_after INTEGER NOT NULL DEFAULT 0, -- set this after updating so we can easily search for new things to update
                    -- notification_mode INTEGER NOT NULL DEFAULT 1, -- 0: All, 1: NoPing, 2: None

                    disabled INTEGER NOT NULL DEFAULT 0,

                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY("map_uid") REFERENCES maps(uid),
                    FOREIGN KEY("player_id") REFERENCES players(wsid)
                );
                CREATE INDEX ix_watchrule_map_uid ON __TABLE_NAME__(map_uid);
                CREATE INDEX ix_watchrule_subject_type ON __TABLE_NAME__(subject_type);
                CREATE INDEX ix_watchrule_update_after ON __TABLE_NAME__(update_after);
                CREATE INDEX ix_watchrule_disabled ON __TABLE_NAME__(disabled);
            """;
            migrations.InsertLast(createTable.Replace("__TABLE_NAME__", name));
            migrations.InsertLast("CREATE UNIQUE INDEX ix_wrule_map_subj_wsid ON watchers(map_uid, subject_type, player_id);");
            migrations.InsertLast("ALTER TABLE watchers ADD COLUMN run_count INTEGER DEFAULT 0;");
        }
    }

    // data point for number of players for a specific map
    class MapNbPlayers : TableSpec {
        MapNbPlayers() {
            name = "map_nb_players";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }

        void InsertMigrations() {
            migrations.InsertLast("""
                CREATE TABLE map_nb_players (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    map_uid VARCHAR(32) NOT NULL,
                    nb_players INTEGER NOT NULL,
                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY("map_uid") REFERENCES maps(uid)
                );
                CREATE INDEX ix_nb_players_map_uid ON map_nb_players(map_uid);
            """);
            migrations.InsertLast("ALTER TABLE map_nb_players ADD COLUMN last_highest_score INTEGER DEFAULT 0;");
        }
    }

    // class MapPlayerTimes : TableSpec {
    //     MapPlayerTimes() {
    //         name = "map_player_times";
    //         InsertMigrations();
    //         expectedVersion = migrations.Length;
    //     }

    //     void InsertMigrations() {
    //         migrations.InsertLast("""
    //             CREATE TABLE map_player_times (
    //                 id INTEGER PRIMARY KEY AUTOINCREMENT,
    //                 map_uid VARCHAR(32) NOT NULL,
    //                 time INTEGER NOT NULL,
    //                 player_id VARCHAR(64) NOT NULL,
    //                 created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    //                 FOREIGN KEY("map_uid") REFERENCES maps(uid),
    //                 FOREIGN KEY("player_id") REFERENCES players(wsid)
    //             );
    //             CREATE INDEX ix_times_map_uid ON map_player_times(map_uid);
    //             CREATE INDEX ix_times_player_id ON map_player_times(player_id);
    //         """);
    //     }
    // }

    // class MapPlayerRanks : TableSpec {
    //     MapPlayerRanks() {
    //         name = "map_player_ranks";
    //         InsertMigrations();
    //         expectedVersion = migrations.Length;
    //     }

    //     void InsertMigrations() {
    //         migrations.InsertLast("""
    //             CREATE TABLE map_player_ranks (
    //                 id INTEGER PRIMARY KEY AUTOINCREMENT,
    //                 map_uid VARCHAR(32) NOT NULL,
    //                 rank INTEGER NOT NULL,
    //                 player_id VARCHAR(64) NOT NULL,
    //                 created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    //                 FOREIGN KEY("map_uid") REFERENCES maps(uid),
    //                 FOREIGN KEY("player_id") REFERENCES players(wsid)
    //             );
    //             CREATE INDEX ix_times_map_uid ON map_player_ranks(map_uid);
    //             CREATE INDEX ix_times_player_id ON map_player_ranks(player_id);
    //         """);
    //     }
    // }

    class MapTimesTable : TableSpec {
        MapTimesTable() {
            name = "map_times";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }

        void InsertMigrations() {
            migrations.InsertLast("""
                CREATE TABLE map_times (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    map_uid VARCHAR(32) NOT NULL,
                    batch_number INTEGER NOT NULL,
                    rank INTEGER NOT NULL,
                    time INTEGER NOT NULL,
                    player_id VARCHAR(64) NOT NULL,
                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY("map_uid") REFERENCES maps(uid),
                    FOREIGN KEY("player_id") REFERENCES players(wsid)
                );
                CREATE INDEX ix_times_map_uid ON map_times(map_uid);
                CREATE INDEX ix_times_player_id ON map_times(player_id);
            """);
        }
    }

    class NotifyRulesTable : TableSpec {
        NotifyRulesTable() {
            name = "notify_rules";
            InsertMigrations();
            expectedVersion = migrations.Length;
        }

        void InsertMigrations() {
            migrations.InsertLast("""
                CREATE TABLE notify_rules (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    map_uid VARCHAR(32) NOT NULL,
                    batch_number INTEGER NOT NULL,
                    rank INTEGER NOT NULL,
                    time INTEGER NOT NULL,
                    player_id VARCHAR(64) NOT NULL,
                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY("map_uid") REFERENCES maps(uid),
                    FOREIGN KEY("player_id") REFERENCES players(wsid)
                );
                CREATE INDEX ix_times_map_uid ON notify_rules(map_uid);
                CREATE INDEX ix_times_player_id ON notify_rules(player_id);
            """);
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
                    map_uid VARCHAR(32) NOT NULL,
                    wr_pre_id INTEGER NOT NULL, -- watch rule
                    wr_post_id INTEGER NOT NULL, -- watch rule

                    me_id INTEGER NOT NULL, -- map event
                    msg TEXT NOT NULL,
                    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY("map_uid") REFERENCES maps(uid),
                    FOREIGN KEY("wr_pre_id") REFERENCES watch_rules(id),
                    FOREIGN KEY("wr_post_id") REFERENCES watch_rules(id)
                    -- FOREIGN KEY("me_id") REFERENCES map_events(id)
                );
            """);
        }
    }
}
