; 2004-02-15	johannes lerch, (v++)
; 2004-07-17	earl

make object! [

    ; template snips:
    ;	- template-comments-brief
    ;	- template-comments-item
    ;	- template-comments-create
    ;	- template-comments-nocomments
    ;	- template-comments-loginfirst
    ;	- template-comments-editlink

    libdj: do load to-file rejoin [ app-dir "dj2/" "libdj2.r" ]

    get-comments-for: func [ s /local res n c ] [
	res: copy []
	n: 1 forever [
	    if not space-exists? c: rejoin [ "comment-" s "-" n ] [ 
		break 
	    ]

	    append res c
	    n: n + 1
	]
	res
    ]

    handle: func [ snipname /local comments ] [
	if none? snipname [ snipname: copy snip ]

	if attempt [ comment-content ] 
	    [ return do-create-comment snipname ]
	if not = snip snipname
	    [ return do-show-brief snipname ]
	do-show-items snipname
    ]

    do-create-comment: func [ s /local cs c ] [
	if none? attempt [ comment-create ] [ 
	    return "we detected an internal error in the comments fabric!"
	]

	c: rejoin [ "comment-" s "-" (1 + length? get-comments-for s) ]
	store-raw c comment-content
	http-redir rejoin [ vanilla-base-url vanilla-display-url s ]
    ]

    do-show-brief: func [ s /local cs tmp us u res ] [
	cs: get-comments-for s

	; get commenters
	tmp: copy []
	foreach c cs [ 
	    if not attempt [
		u: users-get-by-id space-meta-get c "last-editor-id"
		u: u/get 'name
	    ] [
		u: copy "unknown"
	    ]
	    append tmp u 
	]
	; build str
	us: copy ""
	foreach u unique tmp [ append us rejoin [ "*" u "*, " ] ]
	clear skip tail us -2 ; remove trailing ", "

	res: space-expand space-get "template-comments-brief"
	replace/all res "[#comments]" (length? cs)
	replace/all res "[commenters]" either empty? us [ "" ] [ rejoin [ "(by " us ")" ] ]
	replace/all res "[for-snip]" s
	html-format res
    ]

    do-show-items: func [ s /local res tmp cs u ] [
	cs: get-comments-for s

	res: copy ""
	foreach c cs [
	    tmp: space-expand space-get "template-comments-item"

	    ; [content], [age], [author], [name]
	    libdj/expand-snip tmp c

	    ; [edit-button]
	    either all [
		not none? user
		(attempt [ u: users-get-by-id space-meta-get c "last-editor-id" ])
		(= (user/get 'name) (u/get 'name))
	    ] [
		replace/all tmp "[edit-button]" (space-expand space-get "template-comments-editlink")
		replace/all tmp "[name]" c
	    ] [
		replace/all tmp "[edit-button]" ""
	    ]

	    append res tmp
	]

	if = selector "display" [
	    if = 0 length? cs [ 
		append res space-get space-expand "template-comments-nocomments" 
	    ]

	    either not none? user [
		append res space-expand space-get "template-comments-create"
	    ] [
		append res space-expand space-get "template-comments-loginfirst"
	    ]
	]

	replace/all res "[for-snip]" s

	html-format res
    ]

]
