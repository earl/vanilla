; 2000-04-04

REBOL []
	
doc: func [] [
	"reads the current heise.de headlines"
	]


handle: func [] [

	rslt: ""

	news: []
	links: []

	newspage: read http://www.heise.de

	parse newspage [thru <!-- MITTE (NEWS) --> copy newsbody to <!-- MITTE (NEWS-UEBERBLICK) -->]
	parse newsbody [any [thru "/^">" copy text to </a> (append news text)]]
	parse newsbody [any [thru "<A HREF=^"" copy text to "^"" (append links text)]]

	good-news: []
	good-links: []

	foreach item news [
		if not-equal? item "mehr&nbsp;&#133;" [append good-news item]
		]

	forskip links 2 [
		append good-links links/1
		]

	for i 1 length? good-news 1 [
		append rslt "<a href=http://www.heise.de"
		append rslt pick good-links i
		append rslt ">"
		append rslt pick good-news i
		append rslt "</a>, "
		]

	copy/part rslt (length? rslt) - 2

	]