make object! [
	type: [embeddable queryable]
	interface: [[optional name "The name of the person I'll say hello to." [string]]]
	doc: "guess!"
	handle: func [name] [
		either = name none [
			"Hello Vanilloid!"
			] [
			rejoin ["Hello " name "!"]
			] 
		]
	]