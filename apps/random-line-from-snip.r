; 2000-05-08 chl
	
doc: func [] [
	"randomizemebaby"
	]

handle: func [param] [
	rand: space-get param
	rand: parse/all rand "^/"
	random/seed now/time
	numb: random length? rand
	return do rejoin ["rand/" numb]
	]