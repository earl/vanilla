make object! [
    handle: func [ ] [
	if not users-is-master? user [ return "__Only the master can change this!__<br /><br />" ]
	if all [
	    attempt [ do-attach.set-mode ]
	    attempt [ attach-mode ]
	] [
	    space-meta-set "vanilla-attach" 'attach-mode-global attach-mode	
	]
	""
    ]
]
