; chl, 2001-02-19
; earl: 2001-12-24

make object! [
	type: [embeddable]
	interface: [none]
	doc: "shows a list of active users"

	handle: func [sep /local sids sid s uid u us uname ct] [
		us: make hash! []
		res: make string! 256

		sids: sessions-get-all-ids
		foreach sid sids [
			s: sessions-get sid
			uid: s/get 'associated-user-id
			either (= to-string uid "none") [
				uname: "unknown"
				] [
				u: users-get-by-id uid
				uname: u/get 'name
				]

			ct: find us uname
			either none? ct [ repend us [ uname 1 ] ] [
				poke ct 2 (pick ct 2) + 1
				]
			
			]

			
		if (= (length? sids) 0) [ return "<b>no active users</b>"]

		res: rejoin [ "<b>" (length? sids) " active user" ]
		if > length? sids 1 [ append res "s" ]
		append res ":</b><br><br>"

		foreach [ u ct ] us [
			append res html-format rejoin [ "*" u "* (" ct ")" sep ]
			]
		
		copy/part res ((length? res) - (length? sep))
		]
	]
