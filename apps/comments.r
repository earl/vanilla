; chl, 2001-02-27

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
			either (= none uid) [
				append r "*unknown*, "
				] [
				u: users-get-by-id uid
				append r "*"
				append r u/get 'name
				append r "*, "
				]
			]
		copy/part r ((length? r) - 2)
		]
	handle: func [s /local r] [
		du-jour: do load to-file join app-dir %du-jour.r
		r: make string! 1024
		append r du-jour/format-entry to-date s 'comments
		r
		]
	]