; 2001-09-20	earl

make object! [
	doc: func [] [ "" ]

	handle: func [number-of-snips /local result snips snip-list entry displays ] [
		;print "Content-type: text/html^/"
		if = none number-of-snips [ number-of-snips: 50 ]

		result: ""
		snips: []
		snip-list: space-dir
		foreach entry snip-list [
			if (not = (space-meta-get entry "displays") none) [
				append snips space-meta-get entry "displays"
				append snips entry
				]
			]
		snips: sort/skip snips 2
		reverse snips ; sort/reverse/skip snips 2 - in r2.5+

		append result "<ol>"
		foreach [ entry displays ] copy/part snips (to-integer number-of-snips) * 2 [
			append result rejoin [
				"<li> *" entry "* <small>(" displays ")</small>^/"]
			snips: next next snips
			]
		append result "</ol>"

		return result
		]
	]
