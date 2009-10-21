REBOL []
; 2002-06-14    earl
;       * refactored du-jour calendar into a more generic app
; 2002-06-24    earl

make object! [
    doc: "displays a quite generic calendar"

    handle: func [ params /local
        cal-id snip-prefix target-prefix target-appendix
        res cal
        calendar-month calendar-year
        url-appendix entries entry cell vd
    ] [
        ; cal-id: each calendar needs a locally unique id which will be prepended to url-params
        ; snip-prefix, target-prefix, target-appendix:
        ;   if exists? join snip-prefix vd [ create a link to target-prefix vd target-appendix ]

        ; --- param parsing ---
        params: any [ params ";;;;" ]
        set [ cal-id snip-prefix target-prefix target-appendix ] parse/all params ";"
        cal-id:             any [ cal-id "" ]
        snip-prefix:        any [ snip-prefix "" ]
        target-prefix:      any [ target-prefix "" ]
        target-appendix:    any [ target-appendix "" ]

        do load find-file %calendar/lib-core.r

        res: make string! 256
        cal: make calendar []

        ; calendar-month: any [ attempt [ to-integer join cal-id calendar-month ] now/month ]
        ; calendar-year: any [ attempt [ to-integer join cal-id calendar-year ] now/year ]
        either error? try [calendar-month: get to-word join cal-id "calendar-month"]
            [ calendar-month: now/month ]
            [ calendar-month: to-integer calendar-month ]
        either error? try [calendar-year: get to-word join cal-id "calendar-year"]
            [ calendar-year: now/year ]
            [ calendar-year: to-integer calendar-year ]

        url-appendix: rejoin [
            "&" cal-id "calendar-year=" calendar-year
            "&" cal-id "calendar-month=" calendar-month
        ]

        entries: cal/raw-for-month calendar-year calendar-month
        replace/all entries none "&nbsp;"

        append res {<table>}
        forskip entries 7 [
            append res "<tr>"
            foreach entry copy/part entries 7 [
                cell: copy to-string entry
                if not = "&nbsp;" cell [
                    vd: to-vanilla-date to-date rejoin [ calendar-year "-" calendar-month "-" entry ]
                    if space-exists? join snip-prefix vd [
                        cell: rejoin [
                            {<a class="calendar-link" href="}
                                vanilla-display-url target-prefix vd target-appendix url-appendix
                            {">}
                                entry
                            "</a>"
                        ]
                    ]
                ]

                append res rejoin [ {<td class="calendar-item">} cell {</td>} ]
            ]
            append res "</tr>"
        ]
        append res "</table>"

        res
    ]
]
