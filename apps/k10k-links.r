; 2000-04-29
	
doc: func [] [
	"because sometimes k10k feels a bit ... well ... overkilly"
	]

handle: func [/local r link links page] [
	r: ""
	links: []
	page: read http://www.k10k.net/scripts/news/news.asp
	parse page [any [thru "<a href=^"" copy text to "^"" (append links text)]]
	foreach link links [replace link newline "" append r rejoin ["*" link "*" newline]]
	return r
	]