; earl, 2003-03-13

make object! [
    doc: "Outputs the number of days since the first call to itself."

    odb-name: "appdata-online-for"

    handle: func [ ] [
	if not space-exists? odb-name [ space-store odb-name mold now ]
	now - (load space-get odb-name)
    ]
]
