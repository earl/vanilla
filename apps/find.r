; unknown	 chl
; 2001-05-23 earl - added 'title-only-search' functionality
; 2003-03-23 earl - refactored, improved "create" functionality
; 2003-03-24 earl - further cleanup of "create" link; buf fixed, that was introduced yesterday

make object! [
    doc: "searches through the space to find search-string"

    handle: func [/local titleonly result match-list title-match-list] [
	result: copy "" 

	titleonly: false
	if error? try [search-string] [return ""]
	if error? try [ if = title-only-search "true" [ titleonly: true ] ] [ ]

	match-list: copy []
	title-match-list: copy []

	foreach entry space-dir [
	    if find entry search-string [ 
		append title-match-list entry
	    ]
	    if all [ (not titleonly) (find (space-get entry) search-string) ] [
		append match-list entry
	    ]
	]
	title-match-list: sort title-match-list
	match-list: sort match-list

	;;;; create link
	if not find title-match-list search-string [
	    ; if no exact match was found, we'll allow snip creation possibility
	    append result rejoin [ "<p>__no exact match.__ maybe you'd like to *" search-string "*?</p>" ]
	]

	;;;; title output
	append result "<p>__title matches:__ "
	either empty? title-match-list [
	    append result "<i>none</i>"
	] [
	    append result rejoin [ "*" first title-match-list "*" ]
	    foreach entry next title-match-list [
		append result rejoin [", *" entry "*"]
	    ]
	]
	append result "</p>"

	;;;; body output
	if not titleonly [
	    append result "<p>__matches:__ "
	    either empty? match-list [
		append result "<i>none</i>"
	    ] [
		append result rejoin [ "*" first match-list "*" ]
		foreach entry next match-list [
		    append result rejoin [", *" entry "*"]
		]
	    ]
	    append result "</p>"
	]

	return html-format result
    ]

]

; vim: set syn=rebol:
