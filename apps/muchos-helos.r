; 2000-04-15 muchos muchos
	
doc: func [] [
	"guess!"
	]

handle: func [times] [
	retval: ""
	loop to-integer times [append retval rejoin ["hello world, rebol-side" newline]]
	return retval
	]
