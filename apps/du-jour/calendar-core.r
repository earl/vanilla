REBOL []

calendar: make object! [
	month-names: ["January" "February" "March" "April" "May" "June" "July" 
		"August" "September" "October" "November" "December"]
	raw-for-month: func [year month /local days i d lines] [
		; returns a none-pre- and post-filled list of day numbers
		days: make block! 31
		month: to-date rejoin [year "-" month "-1"]
		for i 1 31 1 [either error? try [to-date rejoin [year "-" month/month "-" i]] [] [append days i]]
		either ((28 = length? days) and (1 = month/weekday)) [lines: 4] [lines: 5]
		if ((month/weekday + length? days) > 36) [lines: 6]
		for i 1 (month/weekday - 1) 1 [insert days none] 		; prefill
		for i 1 ((lines * 7) - length? days) 1 [append days none] 	; postfill
		days
		]
	html-for-month: func [year month /local entries res] [
		res: make string! 256
		entries: raw-for-month year month
		lines: (length? entries) / 7
		replace/all entries none "&nbsp;"
		append res "<table>^/"
		for l 1 lines 1 [
			append res "<tr>"
			for i 1 7 1 [
				append res rejoin ["<td>" first entries "</td>"]
				entries: next entries
				]
			append res "</tr>^/"
			]
		append res "</table>"
		res
		]
	]


