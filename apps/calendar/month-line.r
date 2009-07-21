REBOL []
; 2002-06-14    earl
;       * refactoring
; 2002-06-24    earl

make object! [
    doc: "allows everyone and their mother to switch months"
    handle: func [ params /local
        month-abbrevs calendar-month calendar-year
        m-cur m-prev m-next
        link-cur link-prev link-next
        txt-cur txt-prev txt-next
    ] [
        params: any [ params ";" ]
        set [ cal-id ] parse/all params ";"

        month-abbrevs: ["jan" "feb" "mar" "apr" "may" "jun" "jul" "aug" "sep" "oct" "nov" "dec"]

        do load to-file rejoin [ app-dir "calendar/" "lib-core.r" ]

        ; calendar-month: any [ attempt [ to-integer calendar-month ] now/month ]
        ; calendar-year: any [ attempt [ to-integer calendar-year ] now/year ]
        either error? try [calendar-month: get to-word join cal-id "calendar-month"]
            [ calendar-month: now/month ]
            [ calendar-month: to-integer calendar-month ]
        either error? try [calendar-year: get to-word join cal-id "calendar-year"]
            [ calendar-year: now/year ]
            [ calendar-year: to-integer calendar-year ]

        m-cur: to-date rejoin [ calendar-year "-" calendar-month "-" "1" ]
        m-prev: to-date rejoin [ calendar-year "-" calendar-month "-" "1" ]
        m-prev/month: m-prev/month - 1
        m-next: to-date rejoin [ calendar-year "-" calendar-month "-" "1" ]
        m-next/month: m-next/month + 1

        link-prev: rejoin [ "&" cal-id "calendar-year=" m-prev/year {&} cal-id {calendar-month=} m-prev/month ]
        link-next: rejoin [ "&" cal-id "calendar-year=" m-next/year {&} cal-id {calendar-month=} m-next/month ]

        txt-cur: rejoin [ (pick month-abbrevs m-cur/month) " " m-cur/year ]
        txt-prev: pick month-abbrevs m-prev/month
        txt-next: pick month-abbrevs m-next/month

        rejoin [
            "<a href=^"{vanilla-display-url}{.name}" link-prev {">} txt-prev "</a> / "
            txt-cur { / }
            "<a href=^"{vanilla-display-url}{.name}" link-next {">} txt-next "</a>"
        ]
    ]
]
