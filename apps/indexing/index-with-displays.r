; 2000-04-08

make object! [
handle: func [] [
	res: ""
	foreach entry sort space-dir [
		displays: space-meta-get entry "displays"
		append res rejoin ["*" entry "*" " <small>(" displays ")</small>, "]
		]
	copy/part res (length? res) - 2
	]
	
doc: func [] [
	"returns a list of all the snips in the space, with page displays"
	]
]
