; 2000-05-05
; vanilla-du-jour

doc: func [params] [
	"vanilla-du-jour is a simple blog-enabling tool."
	]

vdj-format-date: func [date [date!] /local month-names vdj-nice-date] [
	month-names: ["Januar" "Februar" "M&auml;rz" "April" "Mai" "Juni" "Juli" "August" "September" "Oktober" "November" "Dezember"]
	vdj-nice-date: rejoin [date/day ". " pick month-names date/month " " date/year]
	return vdj-nice-date
	]

handle: func [params /local r day-seperator nof-days date-limit current-nof-days current-date] [
	r: ""
	day-header: space-get "appdata-vanilla-du-jour-header"
	day-footer: space-get "appdata-vanilla-du-jour-footer"

	params: parse params ";"
	nof-days: to-integer params/1
	date-limit: to-date params/2

	current-nof-days: 0
	current-date: now/date ; a cursor

	;r: rejoin ["schours: " nof-days " limit: " date-limit]

	while [(not = date-limit current-date) and (not = nof-days current-nof-days)] [
		if (space-exists? to-vanilla-date current-date) [
			append r day-header
			append r rejoin [{<font size="3">} "<b>" vdj-format-date current-date "</b></font>" newline]
			append r space-get to-vanilla-date current-date
			append r day-footer
			current-nof-days: current-nof-days + 1
			]
		current-date: current-date - 1
		]
	r
	]