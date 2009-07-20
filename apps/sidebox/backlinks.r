; 2001-10-22	earl, chl, rist
;		* incorporated length bugfix
; 2002-04-21	earl
;		* migrated from root appdir, was fast-backlinks.r
; 2003-03-25	earl
;		* minor refactoring

make object! [
	doc: "Returns a list of all the snips which link to the current one."
	handle: func [/local result result-list] [
		result: "" 
		result-list: sort any [ (space-meta-get space-expand "{.name}" "fast-backlinks") [] ]
		either empty? result-list [ 
			append result {<span style="color:black;"><b>no backlinks</b></span>} 
		] [ 
			append result {<span style="color:black;"><b>backlinks:</b></span><br>} 
			until [
				append result rejoin [ "<br>*" (first result-list) "*" ]
				tail? result-list: next result-list
			]
		]
		return html-format result
	]
]
