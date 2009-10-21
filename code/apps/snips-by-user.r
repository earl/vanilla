; 2003-04-13    earl - refactoring, cleanup

make object! [
    doc: "show a list of all snips written by a given user"

    handle: func [ uname /local my-uid result result-list ] [
        ;; pre-cond
        my-uid: users-get-id-by-name uname
        if none? my-uid
            [ return rejoin ["<b>snips-by-user dyna-snip:</b> user " uname " not found!"] ]

        ;; get data
        result-list: copy []
        foreach entry space-dir [
            if = my-uid (space-meta-get entry "last-editor-id")
                [ append result-list entry ]
        ]
        result-list: sort result-list

        ;; format data
        result: copy "__this user's snips:__ "
        either empty? result-list [
            append result "<i>none</i> "
        ] [
            append result rejoin [ "*" first result-list "*" ]
            foreach entry next result-list
                [ append result rejoin [ ", *" entry "*" ] ]
        ]

        result
    ]
]
