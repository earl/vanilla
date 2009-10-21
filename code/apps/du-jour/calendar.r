; 2001-10-22    earl
;       * display-url
; 2002-04-28    earl
;       * package-path modifications

make object! [
    doc: "displays a vanilla-du-jour-integrated calendar"
    handle: func [/local cal entry entries entry-vd] [
        do load find-file %du-jour/calendar-core.r

        res: make string! 256
        cal: make calendar []

        either error? try [calendar-month] [calendar-month: now/month] [calendar-month: to-integer calendar-month]
        either error? try [calendar-year] [calendar-year: now/year] [calendar-year: to-integer calendar-year]
        entry-appendix: rejoin ["&calendar-year=" calendar-year "&calendar-month=" calendar-month]
        entries: cal/raw-for-month calendar-year calendar-month
        lines: (length? entries) / 7
        replace/all entries none "&nbsp;"
        append res {<table>}
        for l 1 lines 1 [
            append res "<tr>"
            for i 1 7 1 [
                entry: first entries
                either (integer? entry) [
                    entry-vd: to-vanilla-date to-date rejoin [calendar-year "-" calendar-month "-" entry]
                    ] [
                    entry-vd: "none"
                    ]
                if ((integer? entry) and (space-exists? entry-vd)) [entry:
                    rejoin [
                        "<a href=^"" vanilla-display-url "comments-" entry-vd entry-appendix "^">" entry "</a>"
                        ]
                    ]
                append res rejoin [{<td style="font-size: 8pt; text-align: center;">} entry "</td>"]
                entries: next entries
                ]
            append res "</tr>"
            ]
        append res "</table>"
        res
        ]
    ]
