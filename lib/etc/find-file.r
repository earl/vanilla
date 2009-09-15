REBOL []

searchpath: reduce []

find-file: func [
    "Find FNAME relative to the list of paths in the global SEARCHPATH."
    fname [file! string!]
    /local f p
] [
    if string? fname [fname: to file! fname]
    p: either = #"." first fname [reduce [system/script/path]] [searchpath]
    foreach path p [
        if exists? f: join path fname [
            break/return f
        ]
    ]
]
