; 2004-03-07    johannes lerch, v++
;               * re-build du-jour to item-based
; 2004-07-02    earl

make object! [
    libdj: do load to-file rejoin [ app-dir "dj2/" "libdj2.r" ]

    handle: func [ date /local byte items tmp res template ctime ] [
        byte: complement charset []

        remove-each snip items: space-dir [
            not parse snip [ date #"-" some byte ]
        ]

        ; reverse sort by creation date
        tmp: copy []
        foreach item items [
            ctime: any [ attempt [ space-meta-get item "first-store-date" ] 0 ]
            append tmp ctime
            append tmp item
        ]
        items: sort/skip/reverse tmp 2

        template: space-get "template-du-jour-item"
        res: copy ""
        foreach [ ctime item ] items [
            append res expand-item (copy template) item
        ]
        res
    ]

    expand-item: func [ template item /local u a tmp ] [
        libdj/expand-snip template item

        replace/all template "[title]" (skip item 11)
        replace/all template "[isodate]" (copy/part item 10)
        replace/all template "[fulldate]" libdj/format-date (to-date copy/part item 10)
        template
    ]
]

; vim: set syn=rebol:
