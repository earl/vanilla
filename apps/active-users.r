; chl, 2001-02-19

make object! [
	type: [embeddable]
	interface: [none]
	doc: "shows a list of active users"
	handle: func [sep /local sids sid s uid u] [
		res: make string! 256
		sids: sessions-get-all-ids
		foreach sid sids [
			s: sessions-get sid
			uid: s/get 'associated-user-id
			either (= to-string uid "none") [append res ""] [
				u: users-get-by-id uid
				append res html-format rejoin ["*" u/get 'name "*"]
				append res sep
				]
			]
		if (= (length? res) 0) [return "<b>no logged-in users</b>"]
		insert res "<b>active users:</b><br><br>"
		copy/part res ((length? res) - (length? sep))
		]
	]