make object! [
	doc: "Returns a list of all the snips which link to the current one."
	handle: func [/local result result-list] [
		result: "" 
		result-list: space-meta-get space-expand "{.name}" "fast-backlinks"
		if = result-list none [result-list: []]
		either (= length? result-list 0) 
			[append result {<span style="color:black;"><b>no backlinks</b></span><br>}]
			[append result {<span style="color:black;"><b>backlinks:</b></span><br><br>}]
		foreach entry sort result-list [
			append result rejoin ["*" entry "*<br>"]
			]
		return html-format copy/part result ((length? result) - 2)
		]
	]