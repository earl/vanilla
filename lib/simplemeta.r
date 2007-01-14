REBOL []
; simple meta/escaping handling library
; earl - 2001-11-27
; earl - 2002-06-09
; earl - 2002-08-31

meta-esc: to-char 1

esc-to-meta: func [ data /local tmp ext ] [
    data: copy data
	while [ all [ (tmp: find/tail data "\") (not tail? tmp) (char: first tmp) ] ] [
		replace data 
			join "\" char 
			join meta-esc (mold to-hex to-integer to-char char)
	]
	data
]

meta-to-esc: func [ data /local tmp ext ] [
    data: copy data
	while [ all [ tmp: find/tail data meta-esc ext: copy/part tmp 9 ] ] [
		replace data 
			join meta-esc ext 
			join "\" (to-char to-integer load ext)
	]
	data
]

meta-to-plain: func [ data /local tmp ext ] [
    data: copy data
	while [ all [ tmp: find/tail data meta-esc ext: copy/part tmp 9 ] ] [
		replace data 
			join meta-esc ext 
			(to-char to-integer load ext)
	]
	data
]

meta-to-html: func [ data /local tmp ext src dst ] [
    data: copy data
	while [ all [ tmp: find/tail data meta-esc ext: copy/part tmp 9 ] ] [
		src: join meta-esc ext

		ext: (to-char to-integer load ext)
		dst: switch/default ext [
			#"<"	[ "&lt;" ]
			#">"	[ "&gt;" ]
			#"&"	[ "&amp;" ]
			#"'"	[ "&apos;" ]
			#"^"" 	[ "&quot;" ]
		] [ ext ]

		replace data src dst
	]
	data
]

esc-to-html: func [ data ] [
    meta-to-html esc-to-meta data
]

comment {
	; test cases
	; pass-thru input
	[ esc-to-meta "asdf" ]
	[ meta-to-esc "asdf" ]
	; basic escaping
	[ esc-to-meta "as\df" ]
	; escape the escape
	[ esc-to-meta "as\\df" ]
	; transparent round-trips
	[ meta-to-esc esc-to-meta "as\df" ]
	[ meta-to-esc esc-to-meta "as\\df" ]
	; getting rid of those escapes
	[ meta-to-plain esc-to-meta "as\df" ]
	[ meta-to-plain esc-to-meta "as\\df" ]
	[ meta-to-html esc-to-meta "as\df" ]
	[ meta-to-html esc-to-meta "as\\df" ]

	; \ as last char
	[ esc-to-meta "asdf\" ]
}
