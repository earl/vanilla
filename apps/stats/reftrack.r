; earl 
; 2002-07-31    earl
;       * added basic filter option (for local refs filtering)
; 2003-12-01    earl
;       * bug fixed

make object! [
    doc: "tracks the referers into an appdata snip"

    ; appdata-reftrack: 
    ;   a nested block 
    ;   one block per referer
    ;   each ref block contains 3 elements (snip, datetime, ref)
    ; 
    ; [ [ snip1 datetime1 referer1 ]
    ;   [ snip2 datetime2 referer2 ]
    ;   .... 
    ;   [ snipN datetimeN refererN ]
    ; ]
    handle: func [filter /local ref odb l roll-limit] [
        either error? try [ filter ] 
            [ filter: none ] 
            [ filter: meta-to-plain to-string filter ]

        odb: "appdata-referer"
        roll-limit: 100

        ; odb init
        if not space-exists? odb [ space-store odb mold [] ]
        l: load space-get odb

        ref: select system/options/cgi/other-headers "HTTP_REFERER"
        if all [ ref (not find/any ref filter) ] [
            insert/only l reduce [ (space-expand "{.name}") now ref ]
        ]

        l: copy/part l roll-limit
        space-store odb mold l

        html-format "*refs*"
    ]
]
