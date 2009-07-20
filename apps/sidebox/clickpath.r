; 2002-08-31	earl

make object! [
    handle: func [ /local res odb e ] [
	res: copy ""
	odb: unique any [ (session/get 'clickpath) (copy []) ]

	foreach e odb [
	    append res rejoin [ "*" e "* " newline ]
	]
	remove back tail res ; remove last newline

	html-format res
    ]
]
