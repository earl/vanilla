; 2000-04-03
REBOL []

doc: none

file-list: read %./

print mold file-list

foreach app file-list [
	if app <> %scan-em-all.r [do load app]
	t: doc
	either t == none [print "no documentation available"] [print rejoin [app ": " t]]
	]
