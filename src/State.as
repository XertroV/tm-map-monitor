namespace State {
    Map@[] maps;
    dictionary knownMaps;

    Watcher@[] watchers;
    dictionary knownWatchers;

    Player@[] players;
    dictionary knownPlayers;

    dictionary mapToPb; // uid ->
    dictionary mapToWr;
    dictionary mapToWatchers;

    void AddMap(Map@ m) {
        if (knownMaps.Exists(m.uid)) return;
        dev_trace('Adding map: ' + m.uid);
        knownMaps[m.uid] = @m;
        maps.InsertLast(m);
    }

    bool IsMapKnown(const string &in uid) {
        return knownMaps.Exists(uid);
    }

    Map@ GetMap(const string &in uid) {
        return cast<Map>(knownMaps[uid]);
    }

    void AddPlayer(Player@ p) {
        if (IsPlayerKnown(p.wsid)) return;
        dev_trace('Adding player: ' + p.name);
        knownPlayers[p.wsid] = @p;
        players.InsertLast(p);
    }

    bool IsPlayerKnown(const string &in wsid) {
        return knownPlayers.Exists(wsid);
    }

    Player@ GetPlayer(const string &in wsid) {
        return cast<Player>(knownPlayers[wsid]);
    }


    void AddWatcher(Watcher@ watcher) {
        if (knownWatchers.Exists(watcher.id_str)) return;
        dev_trace('Adding watcher: ' + watcher.id_str);
        knownWatchers[watcher.id_str] = @watcher;
        GetWatchers(watcher.map_uid).InsertLast(watcher);
        watchers.InsertLast(watcher);
    }

    int NbWatchersFor(Map@ map) {
        auto @watchers = GetWatchers(map.uid);
        if (watchers is null) return 0;
        return watchers.Length;
    }

    Watcher@[]@ GetWatchers(const string &in uid) {
        Watcher@[]@ ret = cast<Watcher@[]>(mapToWatchers[uid]);
        if (ret is null) {
            @ret = array<Watcher@>();
            mapToWatchers[uid] = @ret;
        }
        return ret;
    }

    MapTimeRow@ GetMyInfoOn(const string &in uid) {
        // if (!mapToPb.Exists(uid))
        return cast<MapTimeRow>(mapToPb[uid]);
    }
}


void dev_trace(const string &in msg) {
#if DEV
    trace(msg);
#endif
}
