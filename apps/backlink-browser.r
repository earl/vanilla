; earl 2002-03-22

make object! [
	; known tags:
	;  [snip-for]		snip the browser was invoked for
	;  [snip-cur]		currently displayed backlink
	;	[snip-prev]		previous backlink
	;  [snip-next]		next backlink
	;	[lnk-prev]		full url to previous backlink
	;	[lnk-next]		full url to next backlink
	;  [bl-count]		backlink count, displays the total number of backlinks
	;  [bl-curnr]		at which position is the current displayed bl (for 4/16 displays)
	template: { \
		<table \
			cellspacing="0" cellpadding="5" \
			style="border:1px #c9c9c9 solid;" \
			width="100%"> \
			<tr> \
				<td style="background-color:f9f9f9;border-bottom:1px #c9c9c9 dotted;" align="left"> \
					<b>browsing [bl-count] backlinks for: *[snip-for]*</b><br> \
				</td> \
				<td style="background-color:f9f9f9;border-bottom:1px #c9c9c9 dotted;" align="right"> \
					__viewing: *[snip-cur]* ([bl-curnr]/[bl-count])__
				</td> \
			</tr><tr> \
				<td style="background-color:f9f9f9;font-size:12px;" align="left"> \
					__<- <a href="[lnk-prev]">prev</a>__ | [snip-prev] <br> \
				</td> \
				<td style="background-color:f9f9f9;font-size:12px;" align="right"> \
					[snip-next] | __<a href="[lnk-next]">next</a> ->__ <br> \
				</td> \
			</tr> \
		</table> \
		<br> \
		^{[snip-cur]^} \
	}

	backlinks: none

	get-relative-url-snip: func [ blb-cur fun delim reset /local blb-goto blb-url ] [
		either blb-cur = delim backlinks [
			blb-goto: reset backlinks 
		] [
			blb-goto: first fun find backlinks blb-cur
		]
		blb-url: rejoin [ 
			"{vanilla-display-url}{.name}"
			"&blb-for=" (url-encode blb-for) "&blb-cur=" (url-encode blb-goto)
		]

		compose [ (blb-url) (blb-goto) ]
	]

	handle: func [ /local 
        backlinks
		out
		txt-bl-count
		txt-snip-cur txt-snip-for 
		txt-lnk-prev txt-snip-prev
		txt-lnk-next txt-snip-next
	] [
        if none? attempt [ self/backlinks: sort space-meta-get blb-for "fast-backlinks" ] [ return "__nothin__" ]
		if not value? 'blb-cur [ blb-cur: first backlinks ]

		txt-bl-curnr: index? find backlinks blb-cur
		txt-bl-count: length? backlinks
		txt-snip-cur: blb-cur
		txt-snip-for: blb-for
		set [ txt-lnk-prev txt-snip-prev ] get-relative-url-snip blb-cur :back :first :last
		set [ txt-lnk-next txt-snip-next ] get-relative-url-snip blb-cur :next :last :first

		out: copy template
		replace/all out "[bl-curnr]" txt-bl-curnr
		replace/all out "[bl-count]" txt-bl-count
		replace/all out "[snip-cur]" txt-snip-cur
		replace/all out "[snip-for]" txt-snip-for
		replace/all out "[snip-prev]" txt-snip-prev
		replace/all out "[snip-next]" txt-snip-next
		replace/all out "[lnk-prev]" txt-lnk-prev
		replace/all out "[lnk-next]" txt-lnk-next

		out
	]
]
