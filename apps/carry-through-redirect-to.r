make object! [
	doc: "carries through a value from one form to the next"
	handle: func [] [if error? try [redirect-to] [return ""] redirect-to]
	]