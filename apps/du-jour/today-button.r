REBOL []

; ????-??-?? chl
; 2001-10-23	earl
;		* new-url

make object! [
	doc: "displays a 'new' button if du-jour snip for the current day doesn't exist yet"
	handle: func [] [
		either space-exists? vanilla-date [""] [
			rejoin [
				{<input type="button" value="today?" style="border-width:1px;background-color:#f1f1f1;border-color:#aaaaaa;font-family:Verdana;font-size:11px;"}
				{ onClick="document.location.href='} vanilla-new-url vanilla-date "'^">"
				"<br><br>"
				]
			]
		]
	]
