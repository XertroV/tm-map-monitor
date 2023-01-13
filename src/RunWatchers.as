void RunWatchers() {
    while (true) {
        yield();
        Watcher@[] toUpdate;
        for (uint i = 0; i < State::watchers.Length; i++) {
            auto watcher = State::watchers[i];
            if (watcher.update_after <= Time::Stamp) {
                toUpdate.InsertLast(watcher);
                watcher.update_after = Time::Stamp + watcher.update_period;
            }
        }
        yield();
        for (uint i = 0; i < toUpdate.Length; i++) {
            auto watcher = toUpdate[i];
#if DEV
            RunWatcher(watcher);
#else
            try {
                RunWatcher(watcher);
            } catch {
                warn("Exception running watcher: " + getExceptionInfo());
            }
#endif
        }
        yield();

    }
}

bool RunWatcher(Watcher@ watcher) {
    switch (watcher.subject_type) {
        case WatchSubject::NbPlayers: return RunNbPlayersWatcher(watcher);
        case WatchSubject::TopTimes: return RunTopTimesWatcher(watcher);
        case WatchSubject::LocalPlayer: return RunLocalPlayerWatcher(watcher);
        case WatchSubject::AnotherPlayer: return RunAnotherPlayerWatcher(watcher);
    }
    return false;
}


bool RunNbPlayersWatcher(Watcher@ watcher) {
    if (watcher.subject_type != WatchSubject::NbPlayers) throw('bad watcher.subject -- not NbPlayers');
    auto resp = GetNbPlayersForMap(watcher.map_uid);
    if (resp !is null && resp.GetType() == Json::Type::Object) {
        try {
            int nb_players = resp['nb_players'];
            int last_highest_score = resp['last_highest_score'];
            MapNbPlayersRow(watcher.map_uid, nb_players, last_highest_score);
            watcher.UpdateAndSave();
            return true;
        } catch {
            warn('exception creating nb players row: ' + getExceptionInfo());
        }
    }
    watcher.update_after = 0;
    return false;
}

bool RunTopTimesWatcher(Watcher@ watcher) {
    if (watcher.subject_type != WatchSubject::TopTimes) throw('bad watcher.subject -- not TopTimes');

    return true;
}

bool RunLocalPlayerWatcher(Watcher@ watcher) {
    if (watcher.subject_type != WatchSubject::LocalPlayer) throw('bad watcher.subject -- not LocalPlayer');
    auto resp = GetSurrondingRecords(watcher.map_uid, -1, 0, 0);
    if (resp !is null && resp.GetType() == Json::Type::Object) {
        auto global_rec = resp['tops'][0]['top'][0];
        int rank = global_rec['position'];
        int time = global_rec['score'];
        auto mt = MapTimeRow(watcher.map_uid, -1, rank, time, global_rec['accountId'], global_rec['zoneId']);
        State::AddPb(mt);
        return watcher.UpdateAndSave();
    }
    watcher.update_after = 0;
    return false;
}

bool RunAnotherPlayerWatcher(Watcher@ watcher) {
    if (watcher.subject_type != WatchSubject::AnotherPlayer) throw('bad watcher.subject -- not AnotherPlayer');

    return true;
}
