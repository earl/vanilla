; 2000-04-08
; requires: vanilla-date, vanilla-edit-url, space-api
	
doc: func [] [
	"displays the snip for the current date if it exists and a create link otherwise"
	]

handle: func [] [
	either space-exists? vanilla-date
		[rejoin [space-get vanilla-date " <small>[<a href=" vanilla-edit-url vanilla-date ">edit</a>]</small>"]]
		[rejoin ["*" vanilla-date "*"]]
	]
