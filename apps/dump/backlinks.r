make object! [
	doc: "Returns a list of all the snips which link to the current one."
	handle: func [/local result snip-list result-list] [
		result: "" 
		snip-list: space-dir 
		result-list: []
		current-snip-link: rejoin ["*" space-expand "{.name}" "*"]
		foreach entry snip-list [
			if (not = (find/case (space-get entry) current-snip-link) none) and not (not = (find entry "appdata") none) [
				append result-list entry
				]
			]
		either (= length? result-list 0) 
			[append result {<span style="color:black;"><b>no backlinks</b></span> -  }]
			[append result {<span style="color:black;"><b>backlinks:</b></span> -<br><br>}]
		foreach entry sort result-list [
			append result rejoin ["*" entry "* -<br>"]
			]
		return html-format copy/part result ((length? result) - 2)
		]
	]