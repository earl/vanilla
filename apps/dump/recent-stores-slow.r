; 2001-06-07    earl - init
; 2001-06-12    earl - minor bugfix

make object! [
    doc: "shows the most recently edited snips in the space"

    handle: func [num-of-days /local result list i snip changes key obj] [
        result: ""
        if none? num-of-days [ num-of-days: 3 ]

        list: make hash! []

        ; initalise the day hash [day [snips] day [snips]]
        i: 0
        loop num-of-days [
            repend list [ (now/date - i) copy [] ]
            i: i + 1
            ]

        foreach snip space-dir [
            snip-date: space-meta-get snip "last-store-date"
            if not = snip-date none [
                snip-date: to-date snip-date
                if (now - snip-date) < num-of-days [
                    d: select list snip-date/date
                    repend d [ snip-date/time snip ]
                    ]
                ]
            ]

        foreach [key obj] list [
            changes: sort/reverse/skip obj 2
            append result rejoin [ "__" key "__<br>" ]
            foreach [store-time snip] changes [
                append result rejoin [ "*" snip "*" ]
                append result rejoin [ " ... " store-time ]
                if error? try [
                    u: users-get-by-id space-meta-get snip  "last-editor-id"
                    u: u/get 'name
                    ] [
                    u: space-meta-get snip "last-store-addr"
                    ]
                if none? u [ u: "unknown" ]
                append result rejoin [ " ... *" to-string u "*" ]
                append result "<br>"
                ]
            append result "<br>"
            ]

        return html-format result
        ]
    ]
