; 2001-02-12
; updated 2001-05-25 by earl

make object! [
	doc: "show a list of de/associated users"

	print-user-status: func [ u type /local user-status ] [
		user-status: make string! 200

		;; associations
		assoc-action: either (= "true" to-string u/get 'space-associate) [ "deassociate" ] [ "associate" ]
		append user-status rejoin [
			" <small>[<a href={script-name}?selector=display&snip=vanilla-admin-" type 
         "&admin-section=assocs&action=" assoc-action "&id=" u/get 'id ">" assoc-action "</a>]</small></li>"
			]

		;; enablement/disablement
		either users-is-master? user [
			status-action: either (= "true" to-string u/get 'disabled) [ "enable" ] [ "disable" ]
			append user-status rejoin [ 
				" <small>[<a href={script-name}?selector=display&snip=vanilla-admin-" type 
				"&admin-section=user-status&action=" status-action "&id=" u/get 'id ">" status-action "</a>]</small></li>" 
				]
			] [
			user-status
			]
		]

	handle: func [type /local users assocs nonassocs disableds atx natx disx] [
		users: users-get-all
		assocs: make block! 128 nonassocs: make block! 128 disableds: make block! 128

		foreach u users [
			either (= "true" to-string u/get 'space-associate) [
				either (= "none" to-string u/get 'disabled) [append assocs u] [append disableds u]
				] [
				either (= "none" to-string u/get 'disabled) [append nonassocs u] [append disableds u]
				]
			]

		either (length? assocs) > 0 [
			atx: "<b>Associated Users:</b><ul>"
			foreach a assocs [
				append atx rejoin [ 
					"<li>" a/get 'name 
					print-user-status a type
					]
				]
			append atx "</ul>"
			] [
			atx: ""
			]
		either (length? nonassocs) > 0 [
			natx: "<b>Registered Users:</b><ul>"
			foreach a nonassocs [
				append natx rejoin [
					"<li>" a/get 'name 
					print-user-status a type
					]
				]
			append natx "</ul>"
			] [
			natx: ""
			]
		either (length? disableds) > 0 [
			disx: "<b>Disabled Users:</b><ul>"
			foreach a disableds [
				append disx rejoin [
					"<li>" a/get 'name 
					print-user-status a type
					]
				]
			append disx "</ul>"
			] [
			disx: ""
			]
		rejoin [atx natx disx]
		]
	]
