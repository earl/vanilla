; 2004-07-17	earl

make object! [

    handle: func [/local res] [
	if not space-exists? "appdata-sticky" [ return "" ]

	res: copy ""
	foreach s head reverse load space-get "appdata-sticky" [
	    append res rejoin ["*" s "*<br>"]
	]
	html-format res
    ]

]
