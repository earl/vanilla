REBOL []
; 2002-06-14	earl
;		* refactoring

calendar: make object! [
	raw-for-month: func [year month /local days m1 m2 len lines] [
		; returns a none-pre- and post-filled list of day numbers
		days: make block! 31
		m1: to-date rejoin [year "-" month "-1"]
		m2: to-date rejoin [year "-" month "-1"]
		m2/month: m2/month + 1
		m2: m2 - 1

		; prefill
		repeat i (m1/weekday - 1) 
			[ append days none ]
		; days
		repeat i (m2 - m1 + 1)
			[ append days i ]
		; postfill
		len: length? days
		lines: to-integer len / 7
		repeat i (((lines + 1) * 7) - len) // 7
			[ append days none ]

		days
		]

	html-for-month: func [year month /local entries res] [
		res: make string! 256

		entries: raw-for-month year month
		replace/all entries none "&nbsp;"

		append res "<table>^/"
		forskip entries 7 [
			append res "<tr>"
			foreach entry copy/part entries 7 
				[ append res rejoin ["<td>" entry "</td>"] ]
			append res "</tr>^/"
		]
		append res "</table>"

		res
	]
]


