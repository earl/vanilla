; 2000-04-15 ask me, sam!
; 2000-04-22 useable
; synerge vanilla-naju, n'est ce cool?
	
doc: func [] [
	"store vote and then show naju survey results ..."
	]

; dictionary-like access functions
; should be outsourced to utilities.r

naju-vote-get: func [allvotes name] [
	if = allvotes none [return none]
	foreach [key value] allvotes [if (to-string key) = name [return value]]
	return none
	]

naju-vote-set: func [allvotes name value] [
	if = allvotes none [allvotes: []]
	forskip allvotes 2 [if allvotes/1 = name [remove allvotes remove allvotes]]
	allvotes: head allvotes
	insert/only allvotes value
	insert allvotes name
	return allvotes
	]

handle: func [] [
	either = none naju-votes: space-meta-get naju-survey "naju-votes"
		[naju-votes: []
		 naju-votes: naju-vote-set naju-votes naju-key 1
		 space-meta-set naju-survey "naju-votes" naju-votes
			]
		[either = none curval: naju-vote-get naju-votes naju-key
			[naju-votes: naju-vote-set naju-votes naju-key 1]
			[naju-votes: naju-vote-set naju-votes naju-key ((to-integer curval) + 1)]
		 	space-meta-set naju-survey "naju-votes" naju-votes
			]
	; --- formatting ---
	r: ""
	bar-image-url: space-get "appdata-naju-settings"
	naju-answers: []
	total: 0
	curvals: space-meta-get naju-survey "naju-votes"
	surveydata: space-get naju-survey
	surveydata: parse/all surveydata to-string newline
	foreach line surveydata [
		either = line/1 #"Q" 
			[temp: parse/all line ":" naju-q: next temp/2]
			[if = length? temp: parse/all line ":" 2
				[append naju-answers temp/1
				 append naju-answers next temp/2]
			]
		]
	append r "<table>"
	append r rejoin ["<tr><td colspan=3><b>" naju-q "</b><br>&nbsp;</td></tr>"]
	foreach [key val] naju-votes [total: total + val]
	foreach [key value] naju-answers [
		either = none find naju-votes key [] [
		append r "<tr>"
		foreach [votekey votevalue] naju-votes [
			if = votekey key [
				tempp: to-string (votevalue * 100 / total)
				votepercentage: ""
				loop 4 [if not (tempp/1 = none) [append votepercentage tempp/1 tempp: next tempp]]
				append r "<td>"
				append r rejoin [votevalue " <small>(" votepercentage "%)</small> voted for <b>" value "</b>"]
				append r "</td><td width=25>&nbsp;</td><td>"
				append r rejoin ["<img src=" bar-image-url " height=10 width=" (to-integer votepercentage) * 5 ">"]
				append r "</td>"
				]
			]
		append r "</tr>"
		]]
	append r "</table>"
	append r rejoin [newline "Total votes: " total]
	return r
	]