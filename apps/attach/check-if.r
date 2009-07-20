make object! [
    handle: func [ mode ] [
	if not users-is-master? user [ return "disabled" ]
	either = mode any [ (space-meta-get "vanilla-attach" "attach-mode-global") "" ]
	    [ "checked" ]
	    [ "" ]
    ]
]
