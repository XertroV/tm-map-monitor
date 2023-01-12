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
            RunWatcher(watcher);
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

    return true;
}
bool RunTopTimesWatcher(Watcher@ watcher) {
    if (watcher.subject_type != WatchSubject::TopTimes) throw('bad watcher.subject -- not TopTimes');

    return true;
}
bool RunLocalPlayerWatcher(Watcher@ watcher) {
    if (watcher.subject_type != WatchSubject::LocalPlayer) throw('bad watcher.subject -- not LocalPlayer');

    return true;
}
bool RunAnotherPlayerWatcher(Watcher@ watcher) {
    if (watcher.subject_type != WatchSubject::AnotherPlayer) throw('bad watcher.subject -- not AnotherPlayer');

    return true;
}
