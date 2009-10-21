make object! [
    doc: "includes a snip without applying vanilloid formatting rules"
    handle: func [param /local s] [
        s: space-get param
        s: replace/all s "{" "&#123;"
        s: replace/all s "}" "&#125;"
        s: replace/all s "*" "&#042;"
        s: replace/all s "^/" "&#010;"
        s: replace/all s "__" ""
        s
        ]
    ]
