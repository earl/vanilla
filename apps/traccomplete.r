; 2000-04-27
	
doc: func [] [
	"a first shot at a simple logging system for vanilla"
	]

handle: func [/local appdata-snip trackline resolved-remote snipdata] [
	appdata-snip: rejoin ["appdata-traccomplete-" vanilla-date]
	resolved-remote: read to-url rejoin ["dns://" system/options/cgi/remote-addr]
	trackline: rejoin [now " -- __*" space-expand "{.name}" "*__ -- " resolved-remote]
	either space-exists? appdata-snip [
		snipdata: space-get appdata-snip
		append snipdata rejoin [trackline newline]
		space-store appdata-snip snipdata
		] [
		space-store appdata-snip ""
		snipdata: space-get appdata-snip
		append snipdata rejoin [trackline newline]
		space-store appdata-snip snipdata
		]
	""
	]