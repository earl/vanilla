; chl, 2001-06-01
; 2001-06-04 earl - fixed lil' string comparison bug

; originally for freememes.com

make object! [
	handle: func [params /local current-snip split-params snips to-show found] [
		found: false
		current-snip: space-expand "{.name}"
		split-params: parse/all params ";"
		snips: parse/all first split-params ","
		to-show: second split-params

		foreach s snips [
			if all [ 
					(= length? s length? current-snip )
					(not = none find/any current-snip s)
				] [
				found: true
				]
			]

		either not found [
			return space-get to-show
			] [
			return ""
			]
		]
	]
