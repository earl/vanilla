make object! [
    doc: "ignore me!"
    handle: func [mode] [either = (space-meta-get "vanilla-options" "space-mode") mode [return "checked"] [return ""]]
    ]
