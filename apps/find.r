; unknown	 chl
; 2001-05-23 earl - added 'title-only-search' functionality

make object! [

	doc: func [] [
		"searches through the space to find search-string"
		]

	handle: func [/local titleonly result snip-list match-list title-match-list] [
		titleonly: false
		result: "" 
		snip-list: space-dir 
		match-list: copy []
		title-match-list: copy []
		if error? try [search-string] [return ""]
		if error? try [ if = title-only-search "true" [ titleonly: true ] ] [ ]

		foreach entry snip-list [
			if not titleonly [
				if (not = (find (space-get entry) search-string) none) [
					append match-list entry
					]
				]
			if (not = (find entry search-string) none) [
				append title-match-list entry
				]
			]

		; title output
		append result "__title matches:__ "
		foreach entry sort title-match-list [
			append result rejoin ["*" entry "*, "]
			]
		if (= 0 length? title-match-list) [append result "<i>none</i>  "]

		; other matches
		if not titleonly [
			result: copy/part result ((length? result) - 2)
			append result "<br><br>__matches:__ "
			foreach entry sort match-list [
				append result rejoin ["*" entry "*, "]
				]
			if (= 0 length? match-list) [append result "<i>none</i>  "]
			]

		return html-format copy/part result ((length? result) - 2)
		]

	]

; vim: set syn=rebol sw=3:
