; chl 2002-01-20
; earl 2002-0?-?? added overview "tab"

make object! [
	alpha: "abcdefghijklmnopqrstuvwxyz"
	select-snips: func [code /local selected s] [
		selected: copy []
		if not found? find alpha code [
			foreach s snips [
				if not found? find alpha s/1 [append selected s]
				]
			return selected 
			]
		foreach s snips [
			if = uppercase to-string s/1 to-string code [
				append selected s
				]
			]
		selected
		]

	split: func [/local l split-snips] [
		split-snips: copy []
		foreach l join "0" alpha [
			repend split-snips [l select-snips l]
			]
		split-snips
		]

	sort snips: space-dir
	snips: split 

	overview: func [page /local r n] [
		r: copy "<b>"

		either none? page [ append r "Overview " ] [
			append r rejoin [ 
				"<a href=^"" 
				vanilla-display-url 
				"index-alphabetical&index-page="
				"^">Overview</a> " 
				]
			]

		foreach l join "0" alpha [
			either not = page to-string l [
				append r rejoin [
					"<a href=^"" vanilla-display-url 
					"index-alphabetical&index-page=" l
					"^">" uppercase to-string l "</a> " 
					]
				] [
				append r join uppercase to-string l " "
				]
			]
		r: join r "</b>"
		if none? page [
			append r "<hr>"
			append r rejoin ["<table width=^"100%^" "
				"style=^"border:1px #c9c9c9 solid;^"><tr><td valign=^"top^">"]
			color: "#e9e9e9"
			n: 1 foreach l join "0" alpha [
				append r rejoin [
					"<table width=^"100%^"><tr><td>"
					"<b> &nbsp;" uppercase to-string l "</b>"
					"<td><td>" " ... " "</td><td align=^"right^">"
					length? select snips l "&nbsp; " 
					"</td></tr></table>" 
					]
				if = 0 (n // 5) [
					repend r ["</td><td valign=^"top^" bgcolor=^"" color "^">"]
					either = color "#e9e9e9" [color: "#ffffff"] [color: "#e9e9e9"]
					]
				n: n + 1
				]
			append r "</td></tr></table>"
			]
		r	 
		]

	handle: func [/local s r] [
		if any [
			(error? try [index-page])
			(= "" index-page)
			] [ return overview none ]
		
		r: copy "" append r overview index-page
		append r "<hr>"
		foreach s select snips to-char index-page/1 [
			append r rejoin ["*" s "*<br>"]
			]
		r
		]

	]
