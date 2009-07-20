; originally for freememes.com
; chl, 2001-06-01
; 2001-06-04 earl 
;	* fixed lil' string comparison bug
; 2001-10-15 earl
;	* minor performance improvement
; 2003-09-01 earl
;	* bug fixed (comparision on equal length is bogus with wildcards)
;	* dyna discontinued: {!include-if:<snip-to-include>;!<snip1>,<snip2>,<snip3>}
;	  provides equal funtionality

make object! [
    handle: func [params /local current-snip split-params snips to-show found] [
	found: false
	current-snip: space-expand "{.name}"
	split-params: parse/all params ";"
	snips: parse/all first split-params ","
	to-show: second split-params

	foreach s snips [
	    if find/any current-snip s [
		found: true
		break
	    ]
	]

	either not found [
	    return space-get to-show
	] [
	    return ""
	]
    ]
]
