; chl 2001-07-06

make object! [
	doc: "adds a snip to a category (technically, it's rather the other way round)"
	handle: func [] [
		if error? try [category this-snip] [return "__[add-to-category:__ missing parameters <i>category</i> or <i>this-snip</i>]"]
		if = "none" to-string space-meta-get this-snip "categories" [
			space-meta-set this-snip "categories" []
			]
		if not found? find (space-meta-get this-snip "categories") category [
			space-meta-set this-snip "categories" append (space-meta-get this-snip "categories") category
			return rejoin ["Added *" this-snip "* to category <i>" category "</i>."]
			]
		return rejoin ["This snip has been already categorized as " category "."]
		]
	]
