; 2001-02-12, 2001-05-25
; 2001-10-22	earl
;		* display-url
; 2001-12-09	earl
;		* reg + redirect

make object!  [
	doc: "login/logout links"
	handle: func [/local admin] [
		either (= user none) [
        	return rejoin [
				{<a href="} vanilla-display-url {vanilla-user-login&redirect-to={.name}">login</a> or }
				{<a href="} vanilla-display-url {vanilla-user-register&redirect-to={.name}">register</a>}
				]
			] [
			either users-is-associate? user [
				admin: rejoin [ {<a href="} vanilla-display-url {vanilla-user-admin-associate">admin</a> or } ]
				] [
				admin: ""
				]
			if users-is-master? user [
				admin: rejoin [ {<a href="} vanilla-display-url {vanilla-user-admin-master">admin</a> or } ]
				]
			return rejoin [
				user/get 'name ", "
				{<a href="} vanilla-display-url {vanilla-user-preferences">prefs</a>, }
				admin
				{<a href="{vanilla-get-url}?selector=user-logout">logout</a>}]
			]
		]
	]
