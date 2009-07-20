; not needed anymore, because this can be achieved more easily
; by using "{vanilla-display-url}target" anywhere in vanilla

make object! [
	doc: "linkup dyna"
	handle: func [params /local type target url] [
		type: 	first parse/all params ";"	
		target: next find params ";"

		url: switch type [
			"edit" 		[ vanilla-edit-url ]
			"display"	[ vanilla-display-url ]
		]

		join url (url-encode target)
	]
]
