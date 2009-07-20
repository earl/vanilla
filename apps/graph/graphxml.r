; chl 2001-07-16
; updated 2001-11-16 (made more robust)
; updated 2002-04-21 (now outputs graphxml instead of vanilla-vista-xml ;-) 
; updated 2002-05-09 (made simpler and compatible with vv-4)

make object! [
	doc: "generates a graphxml representation of the vanilla link structure"
	edges: copy []
	nodes: copy []
	append-node: func [x] [
		if not found? find nodes x [append nodes x]
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
	assemble-backlinks-for: func [s /local b] [
		append-node s
		if not = none (space-meta-get s "fast-backlinks") [
			foreach b (space-meta-get s "fast-backlinks") [
				append/only edges reduce [b s] 
				append-node b
				]
			]
		] 
	assemble-forward-links-for: func [s /local f] [
		append-node s
		foreach f (links-for s) [
			append/only edges reduce [s f]
			append-node f 
			]
		]	
	build-vanilla-xml: func [/local r edge n] [
		r: {<?xml version="1.0" encoding="ISO-8859-1"?>}
		append r "<GraphXML><graph>"
		foreach n nodes [
			append r rejoin [
				{<node name="} 
				n	
				{"><label>} n {</label>
				</node>}
			]
		]
		edges: unique edges
		foreach edge edges [
			append r rejoin ["<edge source=^"" edge/1 "^" target=^"" edge/2 "^"/>"]
			]
		append r "</graph></GraphXML>"
		r
		]
	handle: func [param /local r for-snip backlink backlinks forward-links] [
		r: copy ""
		
		if error? try [for-snip: xml-for-snip] [for-snip: param]
		if = for-snip none [for-snip: "start"]

		if not space-exists? for-snip [
			return {<GraphXML><graph><node name="no snip"><label>no snip</label></node></graph></GraphXML>}
		] 

		assemble-backlinks-for for-snip
		assemble-forward-links-for for-snip

		backlinks: (space-meta-get for-snip "fast-backlinks")
		if not = none backlinks [
			foreach link backlinks [
				assemble-backlinks-for link
				assemble-forward-links-for link
				]
			]

		forward-links: (links-for for-snip)
		if not = none forward-links [
			foreach link forward-links [
				assemble-backlinks-for link
				assemble-forward-links-for link
				]
			]
		
		; append r mold snip-ids
		; append r "<br>"
		; append r mold edges
		return build-vanilla-xml
		]
	]
