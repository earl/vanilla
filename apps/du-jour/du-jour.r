; first it was vanilla-du-jour, now simply du-jour, since it's a supplied application
; 2000-05-05, 2001-02-19
; 2001-02-26	chl
;	* added commenting
; 2001-10-22	earl
;	* display-url, edit-url
; 2001-11-17	earl
;	* ayago (a year ago)
; 2002-04-28	earl
;	* package path modifications
; 2003-06-13	earl
;	* fixed problem with date-limit param in the future (reported by Volker Nitsch)

REBOL []

make object! [
    doc: "du-jour is a simple blog-enabling tool"
    
    format-date: func [date [date!] /local month-names vdj-nice-date] [
	month-names: ["Januar" "Februar" "M&auml;rz" "April" "Mai" "Juni" "Juli" "August" "September" "Oktober" "November" "Dezember"]
	day-names: ["Montag" "Dienstag" "Mittwoch" "Donnerstag" "Freitag" "Samstag" "Sonntag"]
	vdj-nice-date: rejoin [pick day-names date/weekday ", " date/day ". " pick month-names date/month " " date/year]
	return vdj-nice-date
	]

    format-entry: func [d mode /local 
	    a u age comments current-name tc c user-ids users commenters
	    d2 ayago-url 
	] [
	; two modes: 'individual and 'comments
	; [date] [ayago] [fulldate] [time] [author] [age] [#comments] [commenters] [comments] [content]

	age: do load to-file join app-dir "age.r"
	comments: do load to-file rejoin [ app-dir "du-jour/" "comments.r" ]

	entry-template: space-get "du-jour-entry-template"
	entry-with-comments-template: space-get "du-jour-entry-with-comments-template"

	current-name: to-vanilla-date d
	; a year ago
	d2: d d2/year: d2/year - 1
	ayago-url: rejoin [ {<a href="} vanilla-display-url to-vanilla-date d2 {">aYago</a>} ]
	if not space-exists? to-vanilla-date d2 [ ayago-url: "" ]

	either (= mode 'individual) [e: copy entry-template] [e: copy entry-with-comments-template]
	e: replace/all e "[content]" space-get current-name
	e: replace/all e "[date]" current-name
	e: replace/all e "[ayago]" ayago-url
	e: replace/all e "[fulldate]" format-date d
	e: replace/all e "[age]" age/date-to-age space-meta-get current-name "last-store-date" 
	if error? try 
	    [ u: users-get-by-id space-meta-get current-name "last-editor-id" u: u/get 'name] 
	    [ u: "unknown" ]
	e: replace/all e "[author]" u
	if error? try 
	    [ a: age/date-to-age space-meta-get current-name "last-store-date" ] 
	    [ a: "a long time ago" ]	       
	e: replace/all e "[age]" a
	
	; comments, comments all over the place
	if (not space-exists? join "comments-" current-name) [
	    space-store join "comments-" current-name
		rejoin ["{!du-jour.comments:" current-name "}"]
		]

	e: replace/all e "[#comments]" 
	    rejoin ["<a href=^"" vanilla-display-url "comments-" current-name "^">"
		comments/count-for current-name " comments</a>"]
	commenters: comments/user-names-for current-name
	either (= none commenters) [
	    e: replace/all e "[commenters]" ""
	    ] [
	    e: replace/all e "[commenters]" rejoin [" (by " commenters ") "]
	    ]

	; assemble comments section
	if (not = find e "[comments]" none) [
	    either (= 0 comments/count-for current-name) [
		e: replace/all e "[comments]" rejoin [
		    space-get "comments-header" 
		    "<i>no comments</i><br><br>" 
		    "{!du-jour.comments-new-form}" 
		    space-get "comments-footer"
		    ]
		] [
		tc: make string! 1024
		for i 1 comments/count-for current-name 1 [
		    current-comment: rejoin ["comment-" current-name "-" i]
		    c: space-get "comment-template"
		    c: replace/all c "[age]" age/date-to-age space-meta-get current-comment "last-store-date" 
		    c: replace/all c "[content]" space-get current-comment
		    if error? try [u: users-get-by-id space-meta-get current-comment "last-editor-id" u: u/get 'name] [u: "unknown"]
		    c: replace/all c "[author]" u
		    either (not = user none) [
			either (= (user/get 'name) u) [
			    c: replace/all c "[edit-button]" rejoin [
				{<input type="button" value="edit" style="border-width:1px;background-color:#f1f1f1;border-color:#aaaaaa;font-family:Verdana;font-size:11px;"}
				    {onClick="document.location.href='} 
				    vanilla-edit-url current-comment 
				{'">}
				]
			    ] [
			    c: replace/all c "[edit-button]" ""
			    ]
			] [
			c: replace/all c "[edit-button]" ""
			]
		    append tc c
		    ]
		e: replace/all e "[comments]" rejoin [
		    space-get "comments-header" 
		    tc 
		    "{!du-jour.comments-new-form}" 
		    space-get "comments-footer"
		    ]
		]
	    ]
	    
	e
	]

    handle: func [params /local r e header footer nof-days date-limit current-nof-days current-date] [
	r: make string! 1024
	header: space-get "du-jour-header"
	footer: space-get "du-jour-footer"

	params: parse params ";"
	if (not = 2 length? params) [return "__du-jour error:__ count ya' params, again!"]
	nof-days: to-integer params/1
	date-limit: to-date params/2

	current-nof-days: 0
	current-date: now/date ; a cursor

	while [ (date-limit < current-date) and (not = nof-days current-nof-days) ] [
	    if (space-exists? to-vanilla-date current-date) [
		append r format-entry current-date 'individual
		current-nof-days: current-nof-days + 1
		]
	    current-date: current-date - 1
	    ]
	rejoin [header r footer]
	]

    ]
