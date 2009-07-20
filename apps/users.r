; 2001-02-12	chl
; 2001-05-25 	earl
; 2001-10-22	earl
;		* display-url
; 2002-06-01	earl
;		* plain userlist (adopted from admin-users.r)

make object! [
	doc: "show a list of users"

	handle: func [/local users assocs nonassocs disableds out block title ] [
		users: users-get-all
		assocs: make block! 128 
		nonassocs: make block! 128 
		disableds: make block! 128

		foreach u users [
			either = "none" (to-string u/get 'disabled) 
				[ either = "true" (to-string u/get 'space-associate) 
					[ append assocs u ] 
					[ append nonassocs u ]
				]
				[ append disableds u ]
		]
		
		out: copy ""
		foreach [ block title ] reduce [
			assocs 		"Associated Users" 
			nonassocs 	"Registered Users" 
			disableds 	"Disabled Users" 
		] [			
			if (length? block) > 0 [
				append out rejoin [ "<b>" title ": </b><ul>" ]
				foreach a block 
					[ append out rejoin [ "<li>" a/get 'name "</li>" ] ]
				append out "</ul>"
			]
		]

		out
	]
]
