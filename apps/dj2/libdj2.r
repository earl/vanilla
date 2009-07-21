; 2004-07-02    earl
REBOL []

context [
    age: do load to-file join app-dir "age.r"

    format-date: func [date [date!] /local month-names vdj-nice-date] [
        ; @@ cleanup: load names from snips?
        month-names: ["Januar" "Februar" "M&auml;rz" "April" "Mai" "Juni" "Juli" "August" "September" "Oktober" "November" "Dezember"]
        day-names: ["Montag" "Dienstag" "Mittwoch" "Donnerstag" "Freitag" "Samstag" "Sonntag"]
        vdj-nice-date: rejoin [pick day-names date/weekday ", " date/day ". " pick month-names date/month " " date/year]
        return vdj-nice-date
    ]

    expand-snip: func [ template snipname /local meta ] [
        meta: space-meta-get-all snipname

        use [ u tmp ] [
            u: copy "unknown"
            if attempt [ tmp: users-get-by-id (select meta "last-editor-id") ] [
                u: tmp/get 'name
            ]
            replace/all template "[author]" u

            u: copy "unknown"
            if attempt [ tmp: users-get-by-id (select meta "originator-id") ] [
                u: tmp/get 'name
            ]
            replace/all template "[creator]" u
        ]

        use [ a tmp ] [
            a: copy "a long time ago"
            if tmp: select meta "last-store-date" [
                a: age/date-to-age tmp
            ]
            replace/all template "[age]" a
        ]

        replace/all template "[content]" space-get snipname
        replace/all template "[name]" snipname
        template
    ]
]

; vim: set syn=rebol:
