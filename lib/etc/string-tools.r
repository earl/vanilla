REBOL [
    Title:
        "strain://rebol/string-tools"
    Purpose:
        "Additional string manipulation functions"
    Authors:
        [ "Andreas Bolka" ]
    Contributos:
        [ ]
    Date:
        2004-04-16
    History: [
        2002-12-23      "Initial version as strlib.r"
        2003-03-14      "Renamed to string-tools.r"
        2004-04-05      "Fixed nasty bug in ends-with?"
        2004-04-16      "Renamed 'expand to 'rejoin-with"
    ]
]

begins-with?: func [
    "Checks wether a string begins with a given string."
    string [any-string!]
    pattern [any-string!]
] [
    = pattern copy/part string length? pattern
]

ends-with?: func [
    "Checks wether a string ends with a given string."
    string [any-string!]
    pattern [any-string!]
] [
    = pattern skip tail string -1 * (length? pattern)
]

split: func [
    "Splits a string delimited by delim into a list of delimited sub-strings."
    string [any-string!]
    delim [any-string!]
    /local tokens len pos
] [
    ; efficiency: insert tail is equiv to append, but faster
    tokens: make block! 32
    len: length? delim
    while [ pos: find string delim ] [
        insert tail tokens copy/part string pos
        string: skip pos len
    ]
    insert tail tokens copy string
    tokens
]

rejoin-with: func [
    "Rejoins a block of tokens and seperates them by the given delimiter."
    tokens [block!]
    delim [any-string!]
    /local res token
] [
    res: make block! (2 * length? tokens)
    repeat token tokens [
        repend res [ token delim ]
    ]
    remove back tail res
    rejoin res
]
