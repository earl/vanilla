; earl

make object! [
	doc: "displays the referer appdata"

	;   a nested block 
	;   one block per referer
	;   each ref block contains 3 elements (snip, datetime, ref)
	; 
	; [ [ snip1 datetime1 referer1 ]
	;   [ snip2 datetime2 referer2 ]
	;   .... 
	;   [ snipN datetimeN refererN ]
	; ]
	handle: func [/local ref odb l roll-limit] [
		odb: "appdata-referer"

		; odb init
		if not space-exists? odb [ space-store odb mold [] ]
		l: load space-get odb

		out: copy ""
		foreach bl l [
			append out rejoin [ "to *" bl/1 "*: " bl/2/date " *" bl/3 "*" newline ]
			]

		out
		]
	]
