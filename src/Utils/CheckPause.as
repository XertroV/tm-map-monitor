dictionary _checkPause;
/**
 * Check to see if more ms than the limit have passed since the last pause, and if so, yield.
 */
void CheckPause(const string &in key, uint pause_limit_ms = 3) {
    int64 lastPause;
    if (_checkPause.Get(key, lastPause)) {
        if (lastPause + pause_limit_ms < Time::Now) {
            yield();
            _checkPause[key] = Time::Now;
        }
    } else {
        _checkPause[key] = Time::Now;
    }
}
