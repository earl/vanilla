; 2000-04-13, chl
; this is a silent app

doc: func [] [
	"get daemon"
	]

handle: func [] [
	if error? try [server-to-examine] [return ""]
	remote: open to-url rejoin ["tcp://" server-to-examine ":80"]
	insert remote rejoin ["HEAD / HTTP/1.0" newline newline]
	result: copy remote
	close remote
	result: parse/all result to-string newline
	foreach line result [if = (copy/part line 7) "Server:" [server-soft: replace line "Server: " ""]]
	appdata: space-get "appdata-which-server-software"
	replace appdata "<!--wssreplace-->" rejoin ["<!--wssreplace-->" "*http://" server-to-examine "*: " server-soft newline]
	space-store "appdata-which-server-software" appdata
	return ""
	]
