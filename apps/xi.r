make object! [
	author: "chl"
	date: 2002-02-12

	handle: func [specs /local snip spec placeholder content] [
		specs: parse/all specs ";^/"
		snip: space-get first specs remove specs
		foreach spec specs [
			placeholder: content: copy ""
			parse spec [ 
				copy placeholder to "=" thru "=" copy content to end
				]
			replace/all snip rejoin ["[" placeholder "]"] content 
			]
		snip
		]

	]
