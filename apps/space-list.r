handle: func [] [
	rslt: ""
	foreach entry sort space-dir [
		append rslt rejoin ["*" entry "*" ", "]
		]
	copy/part rslt (length? rslt) - 2
	]
	
doc: func [] [
	"returns a list of all the snips in the space"
	]