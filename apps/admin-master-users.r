; 2001-02-12

make object! [
	doc: "show a list of de/associated users"
	handle: func [/local users assocs nonassocs atx natx] [
		users: users-get-all
		assocs: make block! 128 nonassocs: make block! 128
		foreach u users [
			either (= "true" to-string u/get 'space-associate) [
				append assocs u
				] [
				append nonassocs u
				]
			]
		either (length? assocs) > 0 [
			atx: "<b>Associated Users:</b><ul>"
			foreach a assocs [append atx rejoin ["<li>" a/get 'name " <small>[<a href={script-name}?selector=display&snip=vanilla-admin-master&admin-section=assocs&action=deassoc&id=" a/get 'id ">deassociate</a>]</small></li>"]]
			append atx "</ul>"
			] [
			atx: ""
			]
		either (length? nonassocs) > 0 [
			natx: "<b>Registered Users:</b><ul>"
			foreach a nonassocs [append natx rejoin ["<li>" a/get 'name " <small>[<a href={script-name}?selector=display&snip=vanilla-admin-master&admin-section=assocs&action=assoc&id=" a/get 'id ">associate</a>]</small></li>"]]
			append natx "</ul>"
			] [
			natx: ""
			]
		join atx natx
		]
	]