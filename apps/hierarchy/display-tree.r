; chl 2001-07-06
; chl 2001-11-17 added root

make object! [
	doc: "guess!"
	singletons: copy [] 
	rooted: copy []
	parent-rels: copy []
	parents: copy [] 
	children: copy [] 
	true-roots: copy []
	children-for: func [snip /local r sn] [
		r: copy "<ul>"
		foreach sn rooted [
			; probe mold reduce [snip sn]
			if found? find/only parent-rels reduce [snip sn] [
				append r rejoin ["<li>*" sn "*" children-for sn "</li>"]
				]
			]
		return join r "</ul>"
		]

	handle: func [root /local r snip] [
		r: copy "" 

		foreach snip space-dir [
			if = "none" to-string space-meta-get snip "parent" [
				append singletons snip 
				]
			]
		rooted: exclude space-dir singletons
		foreach snip rooted [
			append/only parent-rels reduce [(space-meta-get snip "parent") snip]
			append parents (space-meta-get snip "parent")
			append children snip
			]
		; is rebol's exclude buggy?!
		foreach snip parents [
			if not found? find children snip [append true-roots snip]
			]
		true-roots: unique sort true-roots
		if not none? root [
			if not space-exists? root [return "[specified root doesn't exist]"]
			true-roots: reduce [root]
			] 
		foreach snip true-roots [
			append r rejoin ["<li>*" snip "*" children-for snip "</li>"]
			]
		rejoin ["<ul>" r "</ul>"]
		]
	]
