make object! [
	doc: "Returns the total hits (display requests) for the snips in the space."
	handle: func [/local total name] [
		total: 0
		foreach name space-dir [
			total: total + to-integer space-meta-get snip "displays"
			]	
		to-string total
		]
	]
