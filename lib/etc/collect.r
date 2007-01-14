REBOL []

; gregg irwin, ladislav mecir, gabriele santilli
; mailing list 2006-05

collect: func [
    {Collects values, returning them as a series.}
    [throw]
    emit [word!]  "Word used to collect values"
    block [block!] "Block to evaluate"
    /into dest [series!] "Where to append results"
] [
    ; Create a new context containing just one word (the EMIT
    ; argument) and set the 'emit word to refer to the new context
    ; word. Note the care taken to suppress possible conflicts and
    ; undesired evaluations.
    emit: reduce [emit]
    emit: first use emit reduce [emit]
    ; close over dest
    use [dst] copy/deep [
        ; copy/deep lets us use just [] as the fallback value here.
        dst: any [:dest []]
        ; make the function used to collect values.
        set emit func [value [any-type!] /only] [
            either only [insert/only tail :dst get/any 'value] [
                insert tail :dst get/any 'value
            ]
            get/any 'value
        ]
        do bind/copy block emit
        head :dst
    ]
]
