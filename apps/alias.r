; 2002-03-31	earl
;   * fixed url-encoding matters
; 2003-05-23	earl
;   * title-only -> full search change

make object! [
    doc: "redirects to a snip specified in name or snip-name"
    handle: func [name /local target] [
	if error? try [ target: any [name snip-name] ] [return ""]
	either space-exists? target [
	    http-redir rejoin [ vanilla-display-url url-encode target ]
	] [
	    http-redir rejoin [ vanilla-display-url "find&search-string=" url-encode target ]
	]
    ]
]
