; 2001-02-12
; updated 2001-05-25 by chris

make object!  [
	doc: "login/logout links"
	handle: func [/local admin] [
		either (= user none) [
			return {<a href="{script-name}?selector=display&snip=vanilla-user-login&redirect-to={.name}">login</a> or <a href="{script-name}?selector=display&snip=vanilla-user-register">register</a>}
			] [
			either users-is-associate? user [admin: {<a href="{script-name}?selector=display&snip=vanilla-admin-associate">admin</a> or }] [admin: ""]
			if users-is-master? user [admin: {<a href="{script-name}?selector=display&snip=vanilla-admin-master">admin</a> or }]
			return rejoin [user/get 'name ", " {<a href="{script-name}?selector=display&snip=vanilla-user-preferences">prefs</a>, } admin {<a href="{script-name}?selector=user-logout">logout</a>}]
			]
		]
	]