context [
	
	doc: "bare-bones templating"
	history: [
		2002-02-12 chl "created"
		2003-12-25 chl "sanitized formatting"
	]

	handle: func [ specs /local snip placeholder content ] [
		specs: parse/all specs ";^/"
		snip: space-get first specs remove specs
		foreach spec specs [
			placeholder: content: copy ""
			parse spec [ 
				copy placeholder to "=" thru "=" copy content to end
			]
			replace/all snip rejoin [ "[" placeholder "]" ] content 
		]
		snip
	]

]
