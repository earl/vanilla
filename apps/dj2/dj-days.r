; 2004-02-22    johannes lerch, v++
;               * re-build du-jour to item-based
; 2004-07-02    earl

make object! [
    libdj: do load to-file rejoin [ app-dir "dj2/" "libdj2.r" ]

    items: none
    days: none

    handle: func [
        param
        /local nof-days num byte space res template t today
    ] [
        ; parameter parsing
        nof-days: to-integer param
        off-days: any [ attempt [ to-integer off-days ] 0 ]

        ; get all du-jour snips
        num: charset [ #"0" - #"9" ]
        byte: complement charset []

        space: copy space-dir
        remove-each snip items: copy space [
            not parse snip [ 4 num #"-" 2 num #"-" 2 num #"-" some byte end ]
        ]
        remove-each snip days: copy space [
            not parse snip [ 4 num #"-" 2 num #"-" 2 num end ]
        ]

        ; pre-create non-existing day snips
        foreach item items [
            if not find days day: copy/part item 10 [
                store-raw day rejoin [ "^{!dj2.dj-items:" day "^}" ]
                append days day
            ]
        ]

        ; remove the future
        today: now/date
        remove-each snip days [
            (to-date snip) > today
        ]

        ; render days
        template: space-get "template-du-jour-day"
        t: copy ""
        foreach day (copy/part (skip (sort/reverse days) off-days) nof-days) [
            append t expand-day (copy template) day
        ]

        res: space-get "template-du-jour"
        replace/all res "[entries]" t
        replace/all res "[off-older]" off-days + nof-days
        replace/all res "[off-younger]" max 0 off-days - nof-days
    ]

    expand-day: func [ template day /local ayago ayago-url u a ] [
        libdj/expand-snip template day

        ayago: to-date day
        ayago/year: ayago/year - 1
        ayago: to-vanilla-date ayago
        ayago-url: ""
        if find days ayago [
            ayago-url: rejoin [ {<a href="} vanilla-display-url ayago {">aYago</a>} ]
        ]
        replace/all template "[ayago]" ayago-url

        replace/all template "[isodate]" day
        replace/all template "[fulldate]" libdj/format-date to-date day
        template
    ]

]

; vim: set syn=rebol:
