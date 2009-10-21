; 2001-07-20    earl

make object! [
handle: func [/local dir entry res] [
    dir: sort space-dir
    res: make string! 1024

    append res "<table style='font-size:10pt;'><colgroup><col><col><col></colgroup>"
    forskip dir 3 [
        append res "<tr>"
        foreach entry (copy/part dir 3) [
            displays: space-meta-get entry "displays"
            append res rejoin [ "<td>*" entry "*" " <small>(" displays ")</small></td>" ]
            ]
        append res "</tr>"
        ]
    append res "</table>"
    return res
    ]

doc: func [] [
    "returns a list of all the snips in the space, with page displays"
    ]
]
