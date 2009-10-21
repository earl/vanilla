; earl
make object! [
    doc: "Returns the physical size of the snips in the space (in bytes)."
    handle: func [/local total name] [
        total: 0
        foreach name space-dir [
            total: total +
                size? to-file rejoin [ simplespace-location url-encode name ".snip" ]
            ]
        to-string total
        ]
    ]
