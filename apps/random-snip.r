make object! [
	doc: "includes a random dyna-snip"
	handle: func [/local list] [
		random/seed now/time
		space-get first random space-dir 
		]
	]