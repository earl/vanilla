; chl 2001-07-06

make object! [
	doc: "shows a listbox which contains the vanilla-categories"
	handle: func [/local r cat categories] [
		r: copy ""
		categories: load space-get "vanilla-categories" to-string newline
		append r {<select name="category">}
		append r {<option value="none">none</option>}
		foreach cat categories [
			append r rejoin [{<option value="} cat/1 {">} cat/2 {</option>}]
			]
		append r "</select>"
		r
		]
	]
