; 2000-05-12 chl

doc: func [] [
	"shows the most recently edited snips in the space"
	]

handle: func [/local result recently-stored-snips snip-list last-store-date last-store-time distance distance-t] [
	result: ""
	recently-stored-snips: []
	snip-list: space-dir
	foreach entry snip-list [
		if (not = (space-meta-get entry "last-store-date") none) [
			last-store-date: space-meta-get entry "last-store-date"
			last-store-time: space-meta-get entry "last-store-time"

			distance: (now/date - last-store-date) * 24 * 60
			distance-t: (now/time - last-store-time)
			distance: distance + (distance-t/hour * 60) + distance-t/minute

			append recently-stored-snips distance
			append recently-stored-snips entry
			]
		]
	recently-stored-snips: sort/skip recently-stored-snips 2
	loop ((length? recently-stored-snips) / 2) [
		append result rejoin ["*" recently-stored-snips/2 "* <small>(" recently-stored-snips/1 ")</small>, "]
		recently-stored-snips: next next recently-stored-snips
		]	
	return copy/part result (length? result) - 2
	]