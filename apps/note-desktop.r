; 2004-07-02    earl - merged into cvs
; 2004-02-09    johannes lerch (v++)

make object! [
    doc: "note desktop (takes appdata snip containing desktop icons as paramter)"

    handle: func [ datasnip /local entries col entry res label ] [
        entries: copy ""
        col: 1
        foreach snip parse space-get datasnip "" [
            entry: space-get "template-note-desktop-entry"
            label: copy snip
            if 13 < (length? label) [ label: append (copy/part label 13) "..." ]

            replace/all entry "[snip-label]" label
            replace/all entry "[snip-name]" snip
            append entries entry

            either = 0 col // 6 [
                append entries "</tr><tr>"
                col: 1
            ] [
                col: col + 1
            ]
        ]

        res: space-get "template-note-desktop"
        replace/all res "[datasnip]" datasnip
        replace/all res "[entries]" entries
        res
    ]
]
