; chl 2001-07-06

make object! [
	doc: "display the parent hierarchy"
	handle: func [style /local r traversed current-snip current-parent hierarchy] [
		if none? style [style: "nielsen"]
		current-snip: (first next find internal-snips ".name")
		hierarchy: copy []
		traversed: copy []
		r: copy ""
		while [not = "none" to-string current-parent: space-meta-get current-snip "parent"] [
			if found? find traversed current-parent [remove hierarchy break]
			insert hierarchy current-parent
			insert traversed current-parent
			current-snip: current-parent
			]
		foreach current-snip hierarchy [
			append r html-format rejoin ["*" current-snip "* : "]
			]
		return r
		]
	]
