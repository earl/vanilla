; chl 2001-02-19
; generalized 2001-02-26

make object! [
	doc: "shows the age of the currently displayed snip"
	date-to-age: func [d [date!] /local t dd] [
		if (not = 0 (now/date - d/date)) [
			either (= (now/date - d/date) 1) [dd: " day"] [dd: " days"]
			return rejoin [(now/date - d/date) dd]
			]
		t: now/time - d/time
		if (= 0 t/minute) [return "just a blink of an eye"]
		either (= 1 t/hour) [dd: ""] [dd: "s"]
		if (= 0 t/hour) [return rejoin [t/minute " minutes"]]
		return rejoin [t/hour " hour" dd ", " t/minute " minutes"]
		]
	handle: func [] [
		if error? try [
			return date-to-age to-date space-meta-get snip "last-store-date"
			] ["a long time"]
		]
	]