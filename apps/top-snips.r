; 2000-04-24 chl
	
doc: func [] [
	"shows the most 'popular' snips in the space"
	]

handle: func [
		nof-snips 
		/local result snip-list snip-list-with-displays entry
	] [
	result: ""
	snip-list: space-dir
	snip-list-with-displays: []
	foreach entry snip-list [
		append snip-list-with-displays (to-integer space-meta-get entry "displays")
		append snip-list-with-displays entry
		]
	snip-list-with-displays: sort/skip snip-list-with-displays 2
	reverse snip-list-with-displays
	loop to-integer nof-snips [
		append result "*"
		append result snip-list-with-displays/1
		append result "* <small>("
		append result snip-list-with-displays/2
		append result ")</small>, "
		snip-list-with-displays: next next snip-list-with-displays
		]
	return copy/part result (length? result) - 2
	]
