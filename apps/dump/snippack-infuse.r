; chl, 2001-07-05

make object! [
	doc: "retrieves a snippack from a http url and infuses it into a space"
	handle: func [/local infusion] [
		if error? try [snippack-infuse-location] [
			return "[__snippack-infuse:__ missing paramter snippack-infuse-location]"
			]
		if error? try [infusion: read to-url join "http://" snippack-infuse-location] [
			return "[__snippack-infuse:__ could not retrieve snippack!]"
			]
		return length? infusion
		]
	]