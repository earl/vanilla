; 2001-09-23    earl
; 2002-03-30    earl, chl - bugfix
; 2002-07-28    earl, chl - bugfix (html-escape-generic is no more :)
; 2007-01-15    earl - adapted to new linking, reformatted

make object! [
    doc: func [] [ "" ]

    handle: func [/local result wanted snip snip-data] [
        result: make string! 1000
        wanted: copy []
        foreach snip space-dir [
            if not any [
                find/any snip "*-template"
                find/any snip "template-*"
            ] [
                snip-data: space-get snip

                foreach link forwardlinks-in snip-data [
                    if not space-exists? link [
                        requestors: select wanted link
                        if none? requestors [
                            repend wanted [ link make block! 0 ]
                            requestors: select wanted link
                        ]

                        append requestors snip
                    ]
                ]
            ]
        ]

        wanted: sort/skip wanted 2
        foreach [ wanted-snip requestors ] wanted [
            requestors: sort unique requestors

            append result rejoin [ "<li> *" wanted-snip "* (" length? requestors ": " ]
            foreach req requestors [ append result rejoin [ "*" req "* " ] ]
            append result ")"
        ]

        return result
    ]
]
