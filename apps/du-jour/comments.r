; chl, 2001-02-27
; 2001-10-14	earl
;		* user-names-for bugfix
; 2002-05-06	earl
;		* package migration

make object! [
	doc: "guess!"
	count-for: func [s /local count] [
		count: 0
		forever [if (not space-exists? rejoin ["comment-" s "-" (count + 1)]) [break] count: count + 1] 
		return count
		]
	user-ids-for: func [s /local all-ids] [
		all-ids: copy []
		for i 1 count-for s 1 [
			append all-ids space-meta-get rejoin ["comment-" s "-" i] "last-editor-id"
			]
		unique all-ids
		]
	user-names-for: func [s /local u r] [
		if (= 0 count-for s) [return none]
		r: make string! 1024
		foreach uid user-ids-for s [
			either = "none" to-string uid [
				append r "*unknown*, "
				] [
				u: users-get-by-id uid
				append r rejoin [ "*" (u/get 'name) "*, " ]
				]
			]
		copy/part r ((length? r) - 2)
		]
	handle: func [s /local r du-jour] [
		du-jour: do load to-file rejoin [ app-dir "du-jour/" "du-jour.r" ]
		r: make string! 1024
		append r du-jour/format-entry to-date s 'comments
		r
		]
	]
