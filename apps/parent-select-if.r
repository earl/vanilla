; chl 2001-07-06

make object! [
	doc: "display the parent hierarchy"
	handle: func [sn /local current-snip] [
		current-snip: (first next find internal-snips ".name")
		if = sn to-string (space-meta-get current-snip "parent") [return "checked"]
		return ""
		]
	]
