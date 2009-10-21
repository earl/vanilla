; 2001-06-07    earl - init
; 2001-06-12    earl - minor bugfix
; 2001-12-07    earl - caching adaption
; 2003-03-14    earl - doesn't display system snips anymore; code refactoring
; 2003-08-09    earl - fixed num-of-days usage

make object! [
    doc: "shows the most recently edited snips in the space"

    handle: func [num-of-days /local result list changes date ] [
        num-of-days: load any [ num-of-days "3" ]

        result: ""
        list: make hash! []

        ; initalise the day hash [day [snips] day [snips]]
        for i 0 num-of-days 1 [
            repend list [ (now/date - i) copy [] ]
        ]

        foreach snip load space-get "sysdata-recent-stores" [
            if all [
                not system-snip? snip
                date: space-meta-get snip "last-store-date"
                date: to-date date
            ] [
                if (now - date) < num-of-days [
                    repend (select list date/date) [ date/time snip ]
                ]
            ]
        ]

        foreach [date changes] list [
            changes: sort/reverse/skip changes 2
            append result rejoin [ "__" date "__<br>" ]
            foreach [store-time snip] changes [
                append result rejoin [ "*" snip "*" " ... " store-time ]
                if error? try [
                    u: users-get-by-id space-meta-get snip  "last-editor-id"
                    u: u/get 'name
                ] [
                    u: space-meta-get snip "last-store-addr"
                ]
                if none? u [ u: "unknown" ]
                append result rejoin [ " ... *" to-string u "*" "<br>" ]
            ]
            append result "<br>"
        ]

        html-format result
    ]
]
