make object! [
	doc: "shows login form only if user is logged in"
	handle: func [/local ct] [
		either (= user none) [
			return {<i>Please <a href="{script-name}?selector=display&snip=vanilla-user-login">log in</a> to post comments!</i>}
			] [
			ct: space-get "comments-new-form-template"
			replace ct "[for-snip]" next find snip "-"
			]
		]
	]