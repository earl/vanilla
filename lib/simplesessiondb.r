; simplesessiondb.r
; 2000-05-31/2000-10-29/2000-11-19

; session prototype object

session!: make object! [
	data: []
	get-all: func [] [data]
	get-all-keys: func [/local r] [r: [] forskip data 2 [append r data/1] r]
	get: func [key /local result] [result: none foreach [k v] data [if (= k key) [result: v]] result]
	erase: func [key] [forskip data 2 [if (= data/1 key) [remove data remove data]] data: head data]
	set: func [key value] [erase key append data key append/only data value]
	]

sessions-generate-id: func [] [
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
	]

sessions-get: func [session-id] [
	return do load to-file rejoin [sessiondb-param session-id ".session"]
	]

sessions-store: func [session-id session] [
	session/set 'last-activity now/time
	save to-file rejoin [sessiondb-param session-id ".session"] session
	]

sessions-delete: func [session-id] [
	; !!! here comes the logging stuff
	not error? try [
		delete to-file rejoin [sessiondb-param session-id ".session"]
		]
	]

sessions-get-all-ids: func [/local raw-dir sessions] [
	sessions: copy []
	raw-dir: read to-file sessiondb-param
	foreach s raw-dir [
		if (= (skip to-string s (length? to-string s) - 8) ".session")
			[append sessions copy/part to-string s (length? to-string s) - 8]
		]
	sessions
	]

sessions-collect: func [/local session session-id age] [
	; loop through all sessions and delete old ones
	; later: enter usage data for statistical purposes into a db
	foreach session-id sessions-get-all-ids [
		session: sessions-get session-id
		age: now/time - session/get 'last-activity
		if (age < -0:00:01) [age: 24:00 + age]
		if (age > vanilla-session-timeout) [
			sessions-delete session-id
			]
		]
	]