make object! [
	author: ["chris langreiter"]
	date: ["2002-01-10"]
	handle: func [n /local r s] [
		n: to-integer any [n 10] r: copy ""
		foreach s copy/part load space-get "sysdata-recent-stores" n [
			append r rejoin ["*" s "*<br>"]
			]
		html-format r
		]
	]
