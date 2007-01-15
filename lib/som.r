REBOL [ title: "vanilla snip object model" ] ; aka snipjects aka sniplib
; $Id $

;;;
;;; som interface (preliminary!)
;;;

;; -- node :: [ type fulltext [attrs]? children* ]
;; -- internal-link attrs: link-text?, link-target
;; -- external-link attrs: link-text?, link-target, pre-colon, post-colon, post-slashes?

;; node-type?: func [ node ] => type
;; node-attrs?: func [ node ] => [attrs]|none
;; node-children?: func [ node ] => [children]

;; nodes-by-type: func [ type nodes ] => [nodes]
;; node-attr: func [ node attr-name ] => attr-value|none

node-type?: func [ node ] [ first node ]
node-fulltext?: func [ node ] [ second node ]
node-attrs?: func [ node ] [ any [ third node copy [] ] ]
node-children?: func [ node ] [ skip node 3 ]

nodes-by-type: func [ type nodes ] [ 
    remove-each node nodes [ not = type node-type? node ] 
]

node-attr: func [ node attr ] [ select node-attrs? node attr ]

;;;
;;; link-node interface
;;;

;; links-in: func [ snipdata ] => [link-nodes]
;; internal-links-in: func [ snipdata ] => [link-nodes]
;; external-links-in: func [ snipdata ] => [link-nodes]
;; forwardlinks-in: func [ snipdata ] => [snipnames]
;; forwardlinks-for: func [ snipname ] => [snipnames]
;; backlinks-for: func [ snipname ] => [snipnames]

links-in: func [ snipdata ] [
    ; map :parse-raw-link raw-links-in snipdata
    collect 'emit [
        foreach link raw-links-in snipdata [
            emit/only parse-raw-link link
        ]
    ]
]

internal-links-in: func [ snipdata ] [
    nodes-by-type 'internal-link links-in snipdata
]

external-links-in: func [ snipdata ] [
    nodes-by-type 'external-link links-in snipdata
]

forwardlinks-for: func [ snipname ] [ forwardlinks-in space-get snipname ]
forwardlinks-in: func [ snipdata ] [
    ; unique map
    ;   func [node] [node-attr node 'link-target]
    ;   internal-links-in snipdata
    unique collect 'emit [
        foreach link-node internal-links-in snipdata [
            emit node-attr link-node 'link-target
        ]
    ]
]

backlinks-for: func [ snipname ] [
    any [ space-meta-get snipname "fast-backlinks" copy [] ]
]

;;;
;;; internal helpers
;;;

raw-links-in: func [ snipdata /local link ] [
    collect 'emit [
        parse esc-to-meta snipdata [
            any [ 
                thru "*" copy link to "*" thru "*" (if link [ emit link ])
            ]
        ]
    ]
]

parse-raw-link: func [ 
    rawlink 
    /local prefixes rules link-text link-target link-prefix
] [
    parse rawlink [
        opt [ copy link-text to ">>" thru ">>" ]
        copy link-target to end
    ]

    prefixes: extract to-block space-expand space-get "vanilla-links" 2
    prefix: find link-target ":"

    either all [ prefix (find prefixes copy/part link-target prefix) ] [
        parse-external-link rawlink link-text link-target 
    ] [
        parse-internal-link rawlink link-text link-target
    ]
]

parse-internal-link: func [ rawlink link-text link-target ] [
    compose/deep [ 
        internal-link (rejoin [ "*" meta-to-esc rawlink "*" ]) [ 
            link-text (attempt [ meta-to-plain link-text ]) 
            link-target (meta-to-plain link-target) 
        ]
    ]
]

parse-external-link: func [ 
    rawlink link-text link-target 
    /local pre-colon post-colon post-slashes 
] [
    parse link-target [
        copy pre-colon to ":" thru ":"
        copy post-colon [ thru "//" copy post-slashes to end | to end ]
    ]

    compose/deep [ 
        external-link (rejoin [ "*" meta-to-esc rawlink "*" ]) [
            link-text (attempt [ meta-to-plain link-text ])
            link-target (meta-to-plain link-target)
            pre-colon (meta-to-plain pre-colon)
            post-colon (meta-to-plain post-colon)
            post-slashes (attempt [ meta-to-plain post-slashes ])
        ]
    ]
]
