; 2001-07-17 	earl	redirection changes
; 2001-08-30	chl	create-backlinks-for inst/ of generate-fast-backlinks

make object! [
	doc: "stores a comment"
	handle: func [/local comments] [
		; check - count cmts - store
		comments: do load to-file join app-dir %comments.r
		if (error? try [comment-content]) [return "__AI detected:__ Factual error in comment!"]
		if (2 > length? comment-content) [return "__AI detected:__ Factual error in comment!"]
		if (= user none) [return "Won't you login, baby?"]
		store-raw rejoin [ "comment-" comment-for-snip "-" (1 + (comments/count-for comment-for-snip))] comment-content

		snip: join "comments-" comment-for-snip
		create-backlinks-for snip	
		http-redir rejoin [ vanilla-base-url vanilla-display-url snip ]	
		;return space-get snip
		""
		]
	]
