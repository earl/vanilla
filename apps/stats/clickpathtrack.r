; 2002-08-31	earl

make object! [
    handle: func [ /local l ] [
	if none? session/get 'clickpath [ session/set 'clickpath copy [] ]

	l: copy session/get 'clickpath
	insert l space-expand "{.name}"
	session/set 'clickpath copy l

	""
    ]
]
