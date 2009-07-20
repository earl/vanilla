; chl 2001-07-16

make object! [
	doc: "generates vanilla-vista-xml, an xml representation of the vanilla link structure"
	snip-ids: copy []
	edges: copy []
	get-id-for-snip: func [n /local r] [
		if none? r: select snip-ids n [
			append snip-ids reduce [n (r: (((length? snip-ids) / 2) + 1))]
			]
		r  
		]
	links-for: func [n /local snip r link links] [
		; *** should be replaced by space-links/forward once that's there ***
		r: copy [] links: copy []
		snip: space-get n
		vanilla-link-rules: to-block space-expand space-get "vanilla-links"
		link-rule: [thru "*" copy link to "*"]
		link: none
		forever [
			parse snip link-rule
			either link = none
				[break]
				[snip: replace/all snip rejoin ["*" link "*"] "" append links link]
			link: none
			]
		foreach link links [
			if (is-internal-link? link) and (space-exists? link) [append r link]
			]
		r
		]
	assemble-backlinks-for: func [s /local b sid] [
		sid: get-id-for-snip s
		foreach b (space-meta-get s "fast-backlinks") [
			append/only edges reduce [get-id-for-snip b sid] 
			]
		] 
	assemble-forward-links-for: func [s /local f sid] [
		sid: get-id-for-snip s
		foreach f (links-for s) [
			append/only edges reduce [sid get-id-for-snip f]
			]
		]	
	build-vanilla-xml: func [/local r edge] [
		r: "<vanillaVistaXML>"
		forskip snip-ids 2 [
			append r rejoin ["<node label=^"" snip-ids/1 "^" id=^"" snip-ids/2 "^"/>"]
			]
		edges: unique edges
		foreach edge edges [
			append r rejoin ["<edge from=^"" edge/1 "^" to=^"" edge/2 "^"/>"]
			]
		append r "</vanillaVistaXML>"
		r
		]
	handle: func [param /local r for-snip backlink] [
		r: copy ""
		
		if error? try [for-snip: vanilla-vista-xml-for-snip] [for-snip: param]
		if = for-snip none [for-snip: "start"]

		assemble-backlinks-for for-snip
		assemble-forward-links-for for-snip

		foreach link (space-meta-get for-snip "fast-backlinks") [
			assemble-backlinks-for link
			assemble-forward-links-for link
			]

		foreach link (links-for for-snip) [
			assemble-backlinks-for link
			assemble-forward-links-for link
			]
		
		; append r mold snip-ids
		; append r "<br>"
		; append r mold edges
		return build-vanilla-xml
		]
	]