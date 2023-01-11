- SQLite db
- each map has a frequency for checking
- most maps just once a day or like every 8 hrs

-

- detailed infos: nb players, top players, times
-



- add map (by UID / TMX ID)
-




map record: mostly static

watcher: what to monitor about a map
- players rank
- players PB
- top times
- nb players

notify rules: when to send a notification. each rule produces a notification with a pair of records
- rank decreases (prior, present)
- player PBs (prior, present)
- player beats your time (yours, theirs)
- anyone beats your time (yours, player)
- someone plays your map (prior, present)
- summary of how many ppl played your map in last X days (prior, present)






player_times: table of player times on a map
player_ranks: table of player ranks on a map
top_times: table of WR/top times on a map (up to top 100 times)
