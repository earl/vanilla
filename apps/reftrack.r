; 2000-04-12, chl
; requires: space-api, cgi-env OR param: "referer", snip: "appdata-reftrack"
	
doc: func [] [
	"appends the REFERER, if present, to appdata-reftrack"
	]

handle: func [] [
	appdata: space-get "appdata-reftrack"
	foreach [key value] system/options/cgi/other-headers [if = key "HTTP_REFERER" [referer: value]]
	if error? try [referer] [return "*refs* (untracked)"]
	trackdata: rejoin [now " *" referer "*" newline]
	append appdata trackdata
	space-store "appdata-reftrack" appdata
	return "*refs*"
	]
