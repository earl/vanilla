; 2000-04-15 ask me, sam!
; synerge vanilla-naju, n'est ce cool?
	
doc: func [] [
	"show a naju survey, suuupaaaa-nicely formatted!"
	]

handle: func [surveydata-snipname] [
	surveydata: space-get surveydata-snipname
	surveydata: parse/all surveydata to-string newline
	naju-answers: []
	naju-formatted: ""
	foreach line surveydata [
		either = line/1 #"Q" 
			[temp: parse/all line ":" naju-q: next temp/2]
			[if = length? temp: parse/all line ":" 2
				[append naju-answers temp/1
				 append naju-answers next temp/2]
			]
		]
	append naju-formatted rejoin ["__" naju-q "__" newline newline]
	append naju-formatted {<form method="GET" action="vanilla.r">}
	append naju-formatted {<input type="hidden" name="selector" value="display">}
	append naju-formatted {<input type="hidden" name="snip" value="app-naju-store-and-show">}
	append naju-formatted rejoin [{<input type="hidden" name="naju-survey" value="} surveydata-snipname {">}]
	foreach [key answer] naju-answers [
		append naju-formatted rejoin [{<input type="radio" name="naju-key" value="} key {"> } answer "</input><br>"]
		]
	append naju-formatted newline
	append naju-formatted {<input type="submit" value="Vote!">}
	append naju-formatted "</form>"
	return naju-formatted
	]
