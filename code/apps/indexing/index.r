make object! [
    doc: "Returns an alphabetically sorted list of all the snips in the space."
    handle: func [/local dir entry res] [
        dir: sort space-dir
        res: make string! 1024
        foreach entry dir [
            append res rejoin ["*" entry "*, "]
            ]
        copy/part res (length? res) - 2
        ]
    ]
