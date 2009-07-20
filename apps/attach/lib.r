; 2003-07-14	earl 

make object! [

    template-main: none
    template-entry: none
    template-noentries: none

    ; ---

    location-for: func [ snip /url /create /local tmp ] [
	tmp: rejoin [ 
	    either url [ resource-url ] [ resource-dir ] 
	    "attachments/" 
	    (url-encode snip) 
	    "/" 
	]

	; file 
	if none? attempt [ url ] [ 
	    tmp: to-file tmp
	    if all [ create (not exists? tmp) ]
		[ make-dir/deep tmp ]
	]
	tmp
    ]

    size-in-kbyte: func [ fpath ] [
	to-integer 1 + ((size? fpath) / 1000)
    ]

    modify-permissions-ok?: func [ for-snip /local modes space-mode user-mode ] [
	modes: copy [
	    "master" 1
	    "assoc" 2
	    "user" 3
	    "any" 4
	]
    
	space-mode: select modes 
	    any [ 
		attempt [ space-meta-get "vanilla-attach" "attach-mode-global" ] 
		"master" 
	    ]

	user-mode: select modes
	    switch true reduce [ 
		users-is-master? user	    [ "master" ]
		users-is-associate? user    [ "assoc" ]
		not none? user		    [ "user" ]
		true			    [ "any" ]
	    ]

	return (user-mode <= space-mode)
    ]

    ; ---

    handle-add: func [ for-snip /local fname ] [
	if not modify-permissions-ok? for-snip [ return ]
	if attempt [ do-attach.add-file ] [ handle-add-file for-snip ]
	if attempt [ do-attach.add-url ] [ handle-add-url for-snip ]
    ]

    handle-add-file: func [ for-snip ] [
	if not all [
	    attempt [ attach-data ]
	    not empty? attach-data/filename
	] [ return "" ]

	;; store to file
	fname: join (location-for/create for-snip) (last parse/all to-rebol-file attach-data/filename "/\")
	write/binary fname attach-data/content
    ]

    handle-add-url: func [ for-snip ] [
	if not all [
	    attempt [ attach-url ]
	    not empty? attach-url
	] [ return "" ]

	;; download file and store locally
	fname: join (location-for/create for-snip) (last parse/all attach-url "/" )
	write/binary fname read/binary to-url attach-url
    ]

    handle-delete: func [ for-snip /local ] [
	if not attempt [ do-attach.delete ] [ return ]
	if not modify-permissions-ok? for-snip [ return ]
	
	;; REBOL cgi checkbox programming idiom
	;; multiple values may be checked, which may result in the following
	;; cases after 'decode-cgi:
	;; 0 - no delete-att, 
	;; 1 - delete-att: val
	;; n - delete-att: [ val1 val2 ] 
	;; 
	;; the following code flattens this to delete-att: []
	delete-att: compose [ (any [ attempt [ delete-att ] [] ]) ]

	foreach att delete-att 
	    [ delete join location-for for-snip att ]
    ]

    handle-list: func [ for-snip /local tmp res res-entries atts ] [
	either all [
	    exists? loc: location-for for-snip 
	    not empty? atts: read loc
	] [
	    res-entries: copy ""
	    foreach att atts [
		tmp: copy template-entry
		tmp: replace/all tmp "[name]" att
		tmp: replace/all tmp "[url]" rejoin [ (location-for/url for-snip) att ]
		tmp: replace/all tmp "[size-in-kbyte]" size-in-kbyte join location-for for-snip att
		append res-entries tmp
	    ]
	] [
	    res-entries: copy template-noentries
	]

	res: copy template-main
	res: replace/all res "[for-snip]" for-snip
	res: replace/all res "[entries]" res-entries
    ]

    ; ---
    
    ; version 2003-09-12 
    decode-multipart-form-data: func [
	p-content-type 
	p-post-data 
	/local list ct bd delim-beg delim-end non-cr non-lf non-crlf mime-part
    ] [
	list: copy []
	if not found? find p-content-type "multipart/form-data" [ return list ]

	ct: copy p-content-type
	bd: join "--" copy find/tail ct "boundary="
	delim-beg: join bd crlf
	delim-end: join crlf bd

	non-cr:     complement charset reduce [ cr ]
	non-lf:     complement charset reduce [ newline ]
	non-crlf:   [ non-cr | cr non-lf ]
	mime-part:  [
	    ( ct-dispo: content: none ct-type: "text/plain" )
	    delim-beg ; mime-part start delimiter
	    "content-disposition: " copy ct-dispo any non-crlf crlf
	    opt [ "content-type: " copy ct-type any non-crlf crlf ]
	    crlf ; content delimiter
	    copy content 
	    to delim-end crlf ; mime-part end delimiter
	    ( handle-mime-part ct-dispo ct-type content )
	]

	handle-mime-part: func [ 
	    p-ct-dispo 
	    p-ct-type 
	    p-content 
	    /local tmp name value val-p 
	] [
	    p-ct-dispo: parse p-ct-dispo {;="}

	    name: to-set-word (select p-ct-dispo "name")
	    either (none? tmp: select p-ct-dispo "filename")
		   and (found? find p-ct-type "text/plain") [
		value: content
	    ] [
		value: make object! [
		    filename: copy tmp
		    type: copy p-ct-type
		    content: either none? p-content [ none ] [ copy p-content ]
		]
	    ]

	    either val-p: find list name 
		[ change/only next val-p compose [ (first next val-p) (value) ] ]
		[ append list compose [ (to-set-word name) (value) ] ]
	]

	use [ ct-dispo ct-type content ] [
	    parse/all p-post-data [ some mime-part "--" crlf ]
	]

	list
    ]

]
