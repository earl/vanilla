REBOL [
    Title:
	"vanilla version of strain://rebol/string-tools"
    Authors:
	[ "Andreas Bolka" ]
    Date:
	2003-07-27
    History: [ 
	2002-12-23	"Initial version as strlib.r" 
	2003-03-14	"Renamed to string-tools.r"
	2003-07-27	"Added to vanilla, removed 'expand function"
    ]
]

begins-with?: func [ 
    "Checks wether a string begins with a given string."
    string [any-string!]
    pattern [any-string!] 
] [
    ; for the sake of efficiency, leave out the "not none?"
    find/part string pattern length? pattern
]

ends-with?: func [ 
    "Checks wether a string ends with a given string."
    string [any-string!]
    pattern [any-string!]
] [
    ; for the sake of efficiency, leave out the "not none?"
    find/reverse/part tail string pattern length? pattern
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
