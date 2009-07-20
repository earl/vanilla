; 2001-09-23	earl
; 2002-03-30	earl, chl - bugfix
; 2002-07-28	earl, chl - bugfix (html-escape-generic is no more :)

make object! [
	doc: func [] [ "" ]

	handle: func [/local result wanted snip snip-data] [
		result: make string! 1000
		wanted: copy []
		foreach snip space-dir [
			if none? find/any snip "*-template" [
				snip-data: space-get snip

				foreach link internal-links-in snip-data [
					if not space-exists? link [
						requestors: select wanted link
						if none? requestors [
							repend wanted [ link make block! 0 ]
							requestors: select wanted link
							]

						append requestors snip
						]
					]
				] ; if
			]

		wanted: sort/skip wanted 2
		foreach [ wanted-snip requestors ] wanted [
			requestors: sort unique requestors

			append result rejoin [ "<li> *" wanted-snip "* (" length? requestors ": " ]
			foreach req requestors [ append result rejoin [ "*" req "* " ] ]
			append result ")"
			]

		return result 
		]
	]
