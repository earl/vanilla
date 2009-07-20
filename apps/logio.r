; 2001-02-12, 2001-05-25
; 2001-10-22	earl
;		* display-url
; 2001-12-09	earl
;		* reg + redirect
; 2004-01-09	johannes lerch (v++)
;		* redesigned to templating
; 2004-07-17	earl

make object!  [

    handle: func [ /local uname ] [
	if none? user [ return space-expand space-get "template-logio-anon" ]

	either users-is-master? user 
	    [ templ: "template-logio-master" ]
	    [ either users-is-associate? user 
		[ templ: "template-logio-assoc" ]
		[ templ: "template-logio-user" ] ]

	return replace (space-expand space-get templ) "[user]" (user/get 'name)
    ]

]
