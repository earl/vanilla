; simplesessiondb.r
; 2000-05-31/2000-10-29/2000-11-19
; extended for locking, chl 2001-11-08

; 2002-05-11	earl
;		* minor enhancements

; session prototype object

session!: make object! [
	data: []
	get-all: func [] [data]
	get-all-keys: func [/local r] [r: [] forskip data 2 [append r data/1] r]
	get: func [key /local result] [result: none foreach [k v] data [if (= k key) [result: v]] result]
	erase: func [key] [forskip data 2 [if (= data/1 key) [remove data remove data]] data: head data]
	set: func [key value] [erase key append data key append/only data value]
	]

; -- locking -- begin --

session-lock: to-file rejoin [sessiondb-param "sessiondb.lock"]

sessions-lock: func [lock-text] [
	either exists? session-lock
		[sessions-wait-release]
		[write session-lock lock-text]
	]

sessions-wait-release: func [/local lock n maxx] [
	n: 1 maxx: 20
	while [exists? session-lock] [wait 0.05 n: n + 1 if (n > maxx) [sessions-release]]
	]

sessions-release: func [] [
	not error? try [delete session-lock]
	]

; -- locking -- end --

sessions-generate-id: func [ /local r ] [
	r: ""
	random/seed now/time
	loop 4 [append r to-string random 16777216 append r "-"]
	return copy/part r ((length? r) - 1)
	]

sessions-valid?: func [session-id /local session age] [
	either (exists? to-file rejoin [sessiondb-param session-id ".session"]) [
		session: sessions-get session-id
		age: now/time - session/get 'last-activity
		if (age < -0:00:00) [age: 24:00 + age]
		if (age > vanilla-session-timeout) [sessions-delete session-id return false]
		return true
		] [
		return false
		]	
	]

sessions-create: func [session-id /local s] [
	s: make session! []
	s/set 'created now
	sessions-store session-id s
	return s
	]

sessions-get: func [session-id] [
	sessions-wait-release
	return do load to-file rejoin [sessiondb-param session-id ".session"]
	]

sessions-store: func [session-id session] [
	sessions-lock "store"
	session/set 'last-activity now/time
	save to-file rejoin [sessiondb-param session-id ".session"] session
	sessions-release
	return session
	]

sessions-delete: func [session-id] [
	; !!! here comes the logging stuff
	sessions-lock "delete"
	not error? try [
		delete to-file rejoin [sessiondb-param session-id ".session"]
		sessions-release
		]
	]

sessions-get-all-ids: func [/local raw-dir sessions] [
	sessions-lock "get-all-ids"
	sessions: copy []
	raw-dir: read to-file sessiondb-param
	foreach s raw-dir [
		if (= (skip to-string s (length? to-string s) - 8) ".session")
			[append sessions copy/part to-string s (length? to-string s) - 8]
		]
	sessions-release
	sessions
	]

sessions-collect: func [/local session session-id age] [
	; loop through all sessions and delete old ones
	; later: enter usage data for statistical purposes into a db
	foreach session-id sessions-get-all-ids [
		either error? try [session: sessions-get session-id] [
			sessions-delete session-id
			] [
			age: now/time - session/get 'last-activity
			if (age < -0:00:01) [age: 24:00 + age]
			if (age > vanilla-session-timeout) [
				sessions-delete session-id
				]
			]
		]	
	]
