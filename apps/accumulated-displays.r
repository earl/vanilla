; 2000-04-25 3:33am started 3:34am done chl
	
doc: func [] [
	"accumulates the displays of all the snips in da space"
	]

handle: func [/local result accu snip-list entry] [
	result: ""
	accu: 0
	snip-list: space-dir
	foreach entry snip-list [
		accu: accu + to-integer space-meta-get entry "displays"
		]
	result: to-string accu
	return result
	]
