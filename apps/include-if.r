; originally as hide-on for freememes.com
; improved to include-if for sock.strain.at

; 2001-06-01 chl
; 2001-06-04 earl 
;	* fixed lil' string comparison bug
; 2001-10-15 earl
;	* minor performance improvement
; 2003-09-01 earl
;	* refactored and improved, now named include-if
; 2003-09-15 earl
;	* finally fixed length behaviour, added regression tests

make object! [

    match: func [ string patterns ] [
	foreach pattern patterns [
	    all [
		; -- if
		any [ 
		    (= length? string length? pattern) 
		    ; or
		    (find pattern "*") 
		]
		; and
		find/any string pattern 

		; -- then match!
		(return true)
	    ]
	]
	; no match -> fail
	false
    ]
	
    
    handle: func [ params /local tmp target invert snips ] [
	; params: {!include-if:<target>;[!]<if1>[,<if2>]}
	current: copy snip
	target: first tmp: parse/all params ";"

	invert: = #"!" first tmp/2
	if invert [ tmp/2: next tmp/2 ]
	patterns: parse/all tmp/2 ","

	either (match current patterns) xor invert
	    [ space-get target ] 
	    [ "" ]
    ]

    ;; --

    regress: func [] [
	all [
	   (match "nuf"	    [ "nuf" ])
	   (match "nuf"	    [ "foo" "nuf" ])
	   (match "nuf"	    [ "foo" "nuf*" ])
	   (match "nuf-nuf" [ "foo" "nuf*" ])
	   (match "nuf-nuf" [ "foo" "nuf-???" ])

	   (not match "nuf-nuf" [ "foo" "nuf" ])
	   (not match "nuf-nuf" [ "foo" "nuf-??" ])
	]
    ]

]
