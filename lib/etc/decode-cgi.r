REBOL [
    Title:
        "decode-cgi patch"
    Author:
        "Andreas Bolka"
    Purpose: {
        patched 'decode-cgi relevant to all REBOL versions
        up to beta 2.5.4 (2.5.5 includes a fix to bug 2.) 
        ---
        1. bugfix to correctly parse empty params like
        name2 in ?name1=val1&name2&name3=val3

        2. bugfix to parse multiple params with the same 
        name to a name-series as in
         >> decode-cgi "name=val1&name=val2"
         == [ name: [ val1 val2 ] ]
    }
]

decode-cgi: func [
     {Converts CGI argument string to a list of words and value strings.}
     args [any-string!] "Starts at first argument word"
     /local list equate value name name-chars val plus-to-space
][
     add-nv: func [ list name value /local val-ptr ] [
            value: either none? value 
                [ copy "" ] 
                [ form dehex (replace/all value "+" " ") ]

            either none? val-ptr: find list to-set-word name [
                 append list compose [ (to-set-word name) (value) ] 
            ] [ 
                 idx: index? next val-ptr
                 poke list idx compose [ (pick list idx) (value) ] 
            ]
     ]

     list: make block! 8
     name-chars: complement charset "&="
     equate:	[ copy name some name-chars value]
     value:     [   "=" value 
                    | "&" (add-nv list name "") 
                    | [ copy val to "&" "&" | copy val to end ] (add-nv list name val)
                ]

     parse/all args [some equate | none]
     list
]
