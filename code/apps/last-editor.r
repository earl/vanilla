; chl 2001-02-19
; 2002-07-28    earl
;       * fixed html-format {.name} to space-expand {.name}

make object! [
    doc: "shows the last editor of the currently displayed snip"
    handle: func [option /local uid u star] [
        either (= option "linked") [star: "*"] [star: ""]
        uid: space-meta-get space-expand "{.name}" "last-editor-id"
        if (= "none" to-string uid) [return html-format-links rejoin [star "unknown" star]]
        u: users-get-by-id uid
        html-format-links rejoin [star u/get 'name star]
        ]
    ]
