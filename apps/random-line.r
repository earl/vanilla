context [

	doc: "displays a random line from the param snip"
	history: [
		2001-07-12 chl "created"
		2003-12-25 chl "sanitized formatting"
	]

	handle: func [ param /local snip lines ] [
		either space-exists? param [
			random parse/all space-get param to-string newline
		] [
			""
		]
	]

]
