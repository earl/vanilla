REBOL []

make object! [
	doc: "displays a 'new' button if du-jour snip for the current day doesn't exist yet"
	handle: func [] [
		either space-exists? vanilla-date [""] [rejoin [{<input type="button" value="today?" style="border-width:1px;background-color:#f1f1f1;border-color:#aaaaaa;font-family:Verdana;font-size:11px;" onClick="document.location.href='{script-name}?selector=new&snip=} vanilla-date "'^"><br><br>"]]
		]
	]