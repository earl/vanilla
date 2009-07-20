; earl - 2002-02-20
make object! [
	author: "earl"
	handle: func [/local snip] [
		; return "aborted early ..."

		foreach snip space-dir [
			purge-backlinks-for snip
			create-backlinks-for snip
			]

		return join "OK: " now
		]
	]
