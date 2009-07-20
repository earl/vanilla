make object! [
	doc: "displays user's e-mail address"
	handle: func [] [
		either = user none [
			""
			] [
			user/get 'email
			] 
		]
	]