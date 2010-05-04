REBOL []

; required imports: space-params, app-dir

; --- utility functions

url-encode: func [str [string!] /local valid-chars res] [
    valid-chars: charset ["*-._" #"a" - #"z" #"A" - #"Z" #"0" - #"9"]
    res: make string! 3 * length? str
    foreach chr str [
        either find valid-chars chr [
            append res chr
        ] [
            either #" " = chr [
                append res "+"
            ] [
                append res "%"
                append res enbase/base to-string chr 16
            ]
        ]
    ]
    res
]

deplus: func [str] [
    replace/all str "+" " "
    str
]

; --- space-interface follows ...

space-locate-snip: func [name /local snip-path chained-space] [
    foreach chained-space space-params [
        snip-path: to-file rejoin [chained-space url-encode name ".snip" ]
        if exists? snip-path [return snip-path]
    ]
    none
]

space-exists?: func [name] [
    not none? space-locate-snip name
]

expand: func [data what /local with-that cache-age cache-quiescence dynasnip-name cached-at] [
    either what/1 = #"!" [
        either what/2 = #"(" [
            parse what [thru "(" copy cache-quiescence to ")"]
            cache-quiescence: to-time load cache-quiescence
            dynasnip-name: next find what ")"
            either (space-exists? rejoin ["cached-" cache-quiescence "-" dynasnip-name]) [
                cached-at: space-meta-get rejoin ["cached-" cache-quiescence "-" dynasnip-name] "cached-at"
                cache-age: (((1 + (now/date - cached-at/date)) * now/time) - cached-at/time)
                either (cache-age < cache-quiescence) [
                    with-that: space-get rejoin ["cached-" cache-quiescence "-" dynasnip-name]
                ] [
                    with-that: space-dyna-exec dynasnip-name
                    space-store rejoin ["cached-" cache-quiescence "-" dynasnip-name] with-that
                    space-meta-set rejoin ["cached-" cache-quiescence "-" dynasnip-name] "cached-at" now
                ]
            ] [
                with-that: space-dyna-exec dynasnip-name
                space-store rejoin ["cached-" cache-quiescence "-" dynasnip-name] with-that
                space-meta-set rejoin ["cached-" cache-quiescence "-" dynasnip-name] "cached-at" now
            ]
        ] [
            with-that: space-dyna-exec next what
        ]
    ] [
        either error? try [pick (find internal-snips what) 2] [
            with-that: space-get what
        ] [
            with-that: select internal-snips what
            if (type? with-that) = word! [
                with-that: get with-that
            ]
        ]
    ]
    replace data rejoin ["{" what "}"] with-that
]

space-expand: func [data] [
    x-rule: [thru "{" copy to-be-xed to "}"]
    to-be-xed: none
    forever [
        parse data x-rule
        either to-be-xed = none
            [return meta-to-esc data]
            [data: expand esc-to-meta data to-be-xed]
        ;print to-be-xed
        to-be-xed: none
    ]
]

space-get: func [name /local loc] [
    either none? loc: space-locate-snip name
        [rejoin ["[describe " name " here]"] ]
        [read to-file loc]
]

space-store: func [name data] [
    if = name "" [return]
    write to-file rejoin [(first space-params) (url-encode name) ".snip" ] data
]

space-delete: func [name /local fname] [
    if = name "" [return false]

    fname: to-file join (first space-params) (url-encode name)
    if not any [
        (exists? join fname ".snip")
        (exists? join fname ".metadata")
    ] [
        return false
    ]

    if exists? join fname ".snip" [delete join fname ".snip" ]
    if exists? join fname ".metadata" [delete join fname ".metadata" ]

    true
]

space-sys-dir: func [/local files snips chained-space] [
    files: copy []
    snips: copy []
    foreach chained-space space-params [append files read to-file chained-space]
    foreach file unique/case files [
        if = (skip to-string file (length? to-string file) - 5) ".snip" [
            append snips dehex deplus copy/part to-string file (length? to-string file) - 5
        ]
    ]
    snips
]

space-dir: func [/local snips] [
    snips: copy []
    foreach s space-sys-dir [
        if not system-snip? s [
            append snips s
        ]
    ]
    snips
]

system-snip?: func [snip] [
    not none? any [
        begins-with? snip "sysdata-"
        begins-with? snip "appdata-"
        begins-with? snip "cached-"
    ]
]

space-dyna-exec: func [call /local name params path dyna err] [
    parse call [copy name to ":" skip copy params to end | copy name to end]
    ; @@ sanitize so that this cannot escape below vanilla-root
    path: join to-file replace/all copy name "." "/" %.r

    if error? try [dyna: do load find-file path] [
        return rejoin ["__[error loading dynasnip__ from " path "__]__"]
    ]

    if error? err: try [return dyna/handle params] [
        print ["-- Dynasnip:" name]
        err
    ]
]

space-meta-get-all: func [snipname] [
    either error? try [
        rslt: load to-file rejoin [(first space-params) url-encode snipname ".metadata"]
    ] [
        return none
    ] [
        return rslt
    ]
]

space-meta-get: func [snipname name] [
    allmd: space-meta-get-all snipname
    if = allmd none [return none]
    foreach [key value] allmd [if (to-string key) = name [return value]]
    return none
]

space-meta-set: func [snipname name value] [
    metadata-filename: to-file rejoin [(first space-params) url-encode snipname ".metadata"]
    allmd: space-meta-get-all snipname
    if = allmd none [allmd: []]
    forskip allmd 2 [if allmd/1 = name [remove allmd remove allmd]]
    allmd: head allmd
    insert/only allmd value
    insert allmd name
    save metadata-filename allmd
]

space-meta-reset: func [snipname] [
    metadata-filename: to-file rejoin [(first space-params) url-encode snipname ".metadata"]
    save metadata-filename []
]
