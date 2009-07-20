; chl 2001-02-19
; generalized 2001-02-26
; 2003-03-18	earl - fixed some bugs, cleaned up code, added regression tests
; 2003-09-13	earl - minor bugfix

; @@ NOTE: uses global 'snip

make object! [
    doc: "shows the age of the currently displayed snip"

    mul: func [ n ] [ copy either n > 1 [ "s" ] [ "" ] ]

    date-to-age: func [d [date! none!] /local ref diff-days diff-time] [
	if none? d [ return "a long time" ]
	ref: now
	diff-days: ref/date - d/date
	diff-time: ref/time - d/time
	if any [ (diff-days > 1) all [ (diff-days = 1) (not negative? diff-time) ] ] [
	    return rejoin [ diff-days " day" (mul diff-days) ]
	]
	if diff-days = 1 [ diff-time: 24:00:00 + diff-time ]
	if any [ (diff-days > 0) (diff-time/hour > 0) ] [
	    return rejoin [ diff-time/hour " hour" (mul diff-time/hour) ", " diff-time/minute " minutes" ]
	]
	if diff-time/minute > 0 [
	    return rejoin [ diff-time/minute " minute" (mul diff-time/minute) ]
	]
	copy "just a blink of an eye"
    ]

    handle: func [] [
	if error? 
	    try [ return date-to-age to-date space-meta-get snip "last-store-date" ] 
	    [ "a long time" ]
    ]

    regress: func [ /local ] [
	all [
	    (= "just a blink of an eye"	(date-to-age (now)))
	    (= "just a blink of an eye"	(date-to-age (now - 00:00:01)))
	    (= "just a blink of an eye"	(date-to-age (now - 00:00:59)))
	    (= "1 minute"		(date-to-age (now - 00:01:00)))
	    (= "59 minutes"		(date-to-age (now - 00:59:00)))
	    (= "1 hour, 0 minutes"	(date-to-age (now - 01:00:00)))
	    (= "1 hour, 59 minutes"	(date-to-age (now - 01:59:00)))
	    (= "2 hours, 0 minutes"	(date-to-age (now - 02:00:00)))
	    (= "23 hours, 59 minutes"	(date-to-age (now - 23:59:00)))
	    (= "1 day"			(date-to-age (now - 24:00:00)))
	    (= "1 day"			(date-to-age (now - 1)))
	]
    ]
]
