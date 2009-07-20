; 2001-07-20	earl

make object! [
	doc: "Returns an alphabetically sorted list of all the snips in the space."
	handle: func [/local dir entry res] [
		dir: sort space-dir
		res: make string! 1024
		
		append res "<table style='font-size:10pt;'><colgroup><col><col><col></colgroup>"
		forskip dir 3 [
			append res "<tr>"
			foreach entry (copy/part dir 3) [
				append res rejoin [ "<td>" "*" entry "*" "</td>" ]
				]
			append res "</tr>"
			]
		append res "</table>"
		return res
		]
]
