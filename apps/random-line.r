; chl, 2001-07-12

make object! [
	doc: "fetches a random line from a snip"
	handle: func [param /local snip lines] [
		snip: space-get param
		lines: parse/all snip to-string newline
		pick lines random length? lines
		]
	]