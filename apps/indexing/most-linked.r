; 2002-02-09	earl

make object! [
	doc: func [] [ "" ]

	handle: func [number-of-snips /local result snips snip-list entry linkct ] [
		;print "Content-type: text/html^/"
		if = none number-of-snips [ number-of-snips: 10 ]

		result: ""
		snips: []
		snip-list: space-dir
		foreach entry snip-list [
			if (not = (space-meta-get entry "fast-backlinks") none) [
				append snips length? load space-meta-get entry "fast-backlinks"
				append snips entry
				]
			]
		snips: sort/skip snips 2
		reverse snips ; sort/reverse/skip snips 2 - in r2.5+

		append result "<ol>"
		foreach [ entry linkct ] copy/part snips (to-integer number-of-snips) * 2 [
			append result rejoin [
				"<li> *" entry "* <small>(" linkct ")</small>^/"]
			snips: next next snips
			]
		append result "</ol>"

		return result
		]
	]
