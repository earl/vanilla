; chl, 2001-07-12

make object! [
	doc: "guess!"
	count-for: func [s /local count] [
		count: 0
		forever [if (not space-exists? rejoin ["comment-" s "-" (count + 1)]) [break] count: count + 1] 
		return count
		]
	handle: func [s /local r] [
		r: make string! 1024
		append r format-entry s
		r
		]
	format-entry: func [sn mode /local age e tc c current-comment user-ids users commenters template] [
		; [author] [age] [content] [edit-button]

		age: do load to-file join app-dir %age.r
		template: space-get "generic-comment-template"
		e: copy ""		

		either (= 0 count-for sn) [
			e: rejoin ["<i>no comments yet for *" sn "*</i><br><br>{!comments-new-form}"]
			] [
			tc: make string! 1024
			for i 1 count-for sn 1 [
				current-comment: rejoin ["comment-" sn "-" i]
				c: copy template
				c: replace/all c "[age]" age/date-to-age space-meta-get current-comment "last-store-date" 
				c: replace/all c "[content]" space-get current-comment
				if error? try [u: users-get-by-id space-meta-get current-comment "last-editor-id" u: u/get 'name] [u: "unknown"]
				c: replace/all c "[author]" rejoin ["*" u "*"]
				either (not = user none) [
					either (= (user/get 'name) u) [
						c: replace/all c "[edit-button]" rejoin [{<input type="button" value="edit" style="border-width:1px;background-color:#f1f1f1;border-color:#aaaaaa;font-family:Verdana;font-size:11px;" onClick="document.location.href='{script-name}?selector=edit&snip=} current-comment {'">}]
						] [
						c: replace/all c "[edit-button]" ""
						]
					] [
					c: replace/all c "[edit-button]" ""
					]
				append tc c
				]
			append e rejoin [tc "{!comments-new-form}"]
			]
		e
		]
	]