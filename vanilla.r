#!/path/to/rebol(.exe) -cs

; prototypical vanilla rewrite in REBOL
; 2000-02-11 	0.0.1i	started
; 2000-03-05	0.1.0i	made (moderately) usable
; 2000-04-03	0.2.0i	made much more usable (expansion, script-exec, ui)
; 2000-04-04	0.2.1	some simple and obvious bugs fixed
; 2000-04-08	0.2.2i	vanilla-date, metadata functions in simple-space added
; 2000-04-20	0.2.3i	display-raw retrofitted, metadata-related bugs fixed
; 2000-04-20	0.2.4i	rewrote POST handling
; 2000-04-22	0.3.0
; 2000-04-26	0.3.1i	display-js added
; 2000-04-28	0.3.2i	minor changes (app-dir killed) (thx rist)
; 2000-04-29	0.3.3i	some restructuring, last-store
; 2000-05-02	0.3.4i	rudimentary display-wml support added
; 2000-05-06	0.3.5i	some fixes (thx wolfgang schmirl)
; 2000-05-07	0.3.6i	updated replace (case sensitivity)
; 2000-05-12	0.4.0i	first sketches of a session tracking/membership system implemented
; 2000-05-29	0.4.1i	sketches, sketches - session system looks acceptable now
; 2000-05-30	0.4.2i	dictionary proto-object usable for sessions and users created
; 2000-10-29	0.4.8i	sessions work, user system (login, logout, master, associate, member) works (in principle)	
; 2000-11-19	0.4.9i	various bugs related to nuances of newer rebols fixed
;			wml support removed (should be outsourced to a separate script)
;			session/user mgmt debugged and interface pushed forward
; 2000-11-26	-	user interface design
; 2000-11-27	-	further integration, adoption of vanillean standards (dynasnips, templates)
; 2000-11-29	-	general cleanup, dynasnip caching, fast-backlinks-on-store
; 2001-02-13	0.5a1	implemented permission system
; 2001-02-27	-	fixed trivial but annoying bug in session code (case: user valid, session not)
; 2001-03-01	0.5pa1	lots of little buglets fixed, first public alpha
; 2001-03-05	-	added redirect-to to user-login
; 2001-05-25		reactivated display-text and display-raw
;
; 2001-05-25   		earl: added originator attribut, incorporated /space/ changes
; 2001-05-28   		chl: new linking
; 2001-07-12		earl: changed 'display*' for enhanced security possibilities
; 2001-07-17		earl: store redirects to display-url
; 2001-07-17		chl: introduced lib
; 2001-08-25		chl: added really fast backlinks (finally!)
; 2001-08-30		0.5 release (!!!), redirect-to exceptions

REBOL [
    Title:  "synerge vanilla/R"
    Authors: ["Christian Langreiter" "Andreas Bolka"]
    Version: 0.5
]

; print "Content-type: text/html^/^/"
; trace true
; print system/options/cgi/content-length

; cgi-param fetching is now on the top i.o. to prevent too easy exploits (variable overwriting)

; GET
params: decode-cgi any [system/options/cgi/query-string ""]

if system/options/cgi/request-method = "POST" [
      tmp: load any [system/options/cgi/content-length "0"]
      either tmp > 0 [
	        buffer: make string! (tmp + 10)
        	while [tmp > 0] [tmp: tmp - read-io system/ports/input buffer tmp]
        	append params decode-cgi buffer
      		] [
		return none
		]
	]      

; utility functions

http-redir: func [url] [
	; print htmlheader
	; print "I should go. Go yourself!"
	print join "Location: " url
	print join "Expires: 0" newline
	quit
	]

get-cookies-raw: func [] [
	foreach [key value] system/options/cgi/other-headers [if = key "HTTP_COOKIE" [return value]]
	return none
	]

get-cookie: func [name] [
	all-cookies: parse to-string get-cookies-raw "; ="
	foreach [key value] all-cookies [if = key name [return value]]
	return none
	]

set-cookie: func [key value path expires] [
	print rejoin ["Set-Cookie: " key "=" value "; " "path=" path "; expires=" expires]
	]

set-cookie-then-redirect: func [key value path expires url] [
	set-cookie key value path expires
	http-redir url
	]

textheader: 	"Content-Type: text/plain^/"
htmlheader: 	"Content-Type: text/html^/"
jsheader: 	"Content-type: script/javascript^/"

; print htmlheader

sys-script-name: system/options/script
script-name: pick parse sys-script-name "/" length? parse sys-script-name "/"

; --- some things which might be in the .conf (or not) ---

vanilla-html-link-prefix: "" ; might be reset in the .conf

do load to-file join script-name ".conf"

do load to-file rejoin [lib-dir space-accessor ".r"]
do load to-file rejoin [lib-dir userdb-accessor ".r"]
do load to-file rejoin [lib-dir sessiondb-accessor ".r"]

do load to-file join lib-dir "secure-hash.r"

vanilla-edit-url: rejoin [ script-name "?selector=edit&snip="]
vanilla-display-url: rejoin [ "/cgi-bin/" script-name "?selector=display&snip="] ; rejoin [ "/space/" ]
vanilla-new-url: rejoin [script-name "?selector=new&snip="]
vanilla-store-url: rejoin [script-name "?selector=store&snip="]

; internal snips are found first by the space-expand function
; ".xxx" snips are metadata attributes of a snip (like .name, .author, .date-last-edit etc.)

internal-snips: [
	"script-version"	0.5.0.1
	"script-name"		script-name
	"now"			now
	"space-id"		vanilla-space-identifier
	"resource-dir"		resource-dir
	]

; --- vanilla misc vars / funcs ---

to-vanilla-date: func [date [date!] /local vdm vdd] [
	either (length? to-string date/month) = 1 [vdm: rejoin ["0" date/month]] [vdm: date/month]
	either (length? to-string date/day) = 1 [vdd: rejoin ["0" date/day]] [vdd: date/day]
	return rejoin [date/year "-" vdm "-" vdd]
	]

vanilla-date: to-vanilla-date now
vanilla-link-rules: []

; --- html formatting functions ---

html-format-paragraphs: func [snip] [
	replace/all snip "^/^/" "<p>"
	snip
	]

html-format-breaks: func [snip] [
	replace/all snip "^/" "<br>"
	snip
	]

html-format-links: func [snip] [
	;vanilla-link-rules: to-block space-expand space-get "vanilla-links"
	link-rule: [thru "*" copy link to "*"]
	link: none
	forever [
		parse snip link-rule
		either link = none
			[return snip]
			[snip: html-link-me-up snip link]
		link: none
		]
	]


is-internal-link?: func [link] [
	; attention: has to be in sync with flexible-link-up
	rules: vanilla-link-rules
	rules: to-block space-expand space-get "vanilla-links"
	pre-colon: none
	noslashes: [copy pre-colon to ":" thru ":" copy post-colon to end]
	slashes: [copy pre-colon to ":" thru "//" copy post-slashes to end]
	parse link [slashes | noslashes]
	found: find rules pre-colon
	; hmmm, have to think about pre-snip-existence-creation of metadata/fast-backlinks ...
	; either (= found none) [either space-exists? link [return true] [return false]] [return false]
	either (= found none) [return true] [return false]
	]

flexible-link-up: func [str /local pre-colon post-colon post-slashes slashes noslashes rules rule full found] [
	full: str
	rules: to-block space-expand space-get "vanilla-links"
	;rules: vanilla-link-rules
	noslashes: [copy pre-colon to ":" thru ":" copy post-colon to end]
	slashes: [copy pre-colon to ":" thru "//" copy post-slashes to end]
	parse str [slashes | noslashes]
	found: find rules pre-colon
	either (= found none) [
		either space-exists? str [
			return rejoin ["<a href=" vanilla-display-url url-encode str ">" str </a>]
			] [
			return rejoin ["[create <a href=" vanilla-html-link-prefix script-name "?selector=new&snip=" url-encode str ">" str </a> "]"]
			]	
		] [
		rule: copy first next found
		replace/all rule 'full full
		replace/all rule 'pre-colon pre-colon
		replace/all rule 'post-colon post-colon
		if (string? post-colon) [replace/all rule 'url-encoded-post-colon url-encode post-colon]
		replace/all rule 'post-slashes post-slashes
		return rejoin rule
		]
	]

html-link-me-up: func [snip link] [
	replace/all snip rejoin ["*" link "*"] flexible-link-up link
	return snip
	]


html-format-bold: func [snip] [
	span-rule: [thru "__" copy span to "__"]
	span: none
	forever [
		parse snip span-rule
		either span = none
			[return snip]
			[replace snip rejoin ["__" span "__"] rejoin ["<b>" span "</b>"]]
		span: none
		]
	]

html-fixup-umlauts: func [snip] [
	replace/case/all snip "ä" "&auml;"
	replace/case/all snip "ö" "&ouml;"
	replace/case/all snip "ü" "&uuml;"
	replace/case/all snip "Ä" "&Auml;"
	replace/case/all snip "Ö" "&Ouml;"
	replace/case/all snip "Ü" "&Uuml;"
	return snip
	]

html-escape-stars: func [snip] [
	replace/all snip "\*" "&#042;"
	]

html-format: func [snip] [
	snip: html-format-paragraphs snip
	snip: html-format-breaks snip
	snip: html-escape-stars snip
	snip: html-format-links snip
	snip: html-format-bold snip
	snip: html-fixup-umlauts snip
	snip
	]

; --- pre-cached backlink generation functions ---
; --- super-fast edition, chl 2001-05-25 ---

internal-links-in: func [snip-data /local links e r] [
	links: copy [] r: copy []
	snip-data: html-escape-stars snip-data
	parse snip-data [any [thru "*" copy text to "*" skip (append links text)]]
	foreach e links [
		if is-internal-link? e [append r e]
		]
	r
	]

modify-backlinks: func [for-snip snip-name f /local old-backlinks] [
	old-backlinks: space-meta-get for-snip "fast-backlinks"
	if none? old-backlinks [old-backlinks: copy []]
	space-meta-set for-snip "fast-backlinks" f old-backlinks to-block mold snip-name
	; print htmlheader probe space-meta-get for-snip "fast-backlinks"
	]

purge-backlinks-for: func [snip-name /local snip-data backlinking-snip] [
	snip-data: space-get snip-name
	foreach backlinking-snip (internal-links-in snip-data) [
		modify-backlinks backlinking-snip snip-name :exclude
		]
	]

create-backlinks-for: func [snip-name /local snip-data snip-to-backlink] [
	snip-data: space-get snip-name
	foreach snip-to-backlink (internal-links-in snip-data) [
		modify-backlinks snip-to-backlink snip-name :union
		]
	]

; --- handler functions ---

new: func [snipname] [
	edit snipname
	]

edit: func [snipname /local snip edit-form] [
	insert internal-snips snipname
	insert internal-snips ".name"
	print htmlheader
	edit-form: replace (space-expand space-get "vanilla-edit-form-template") "[snip-content-for-editing]" space-get snipname
	print replace (space-expand space-get "vanilla-template") "[snip-content]" edit-form 
	]

store-raw: func [snipname snipdata /local recent-edits resolved-remote snip-at-hand uid] [
	replace/all snipdata "^M^/" "^/"
	space-store snipname snipdata

	resolved-remote: read to-url rejoin ["dns://" system/options/cgi/remote-addr]

	space-meta-set snipname "last-store-date" now
	space-meta-set snipname "last-store-addr" resolved-remote

	uid: either (not = none user) [ user/get 'id ] [ none ] 
	; last-editor
	space-meta-set snipname "last-editor-id" uid
	; originator 
	if = none (space-meta-get snipname "originator-id") [
		space-meta-set snipname "originator-id" uid
		]

	if ((space-meta-get snipname "displays") = none) [
		space-meta-set snipname "displays" 0
		] 
	
	]

store: func [snipname snipdata] [
	purge-backlinks-for snipname
	store-raw snipname snipdata
	create-backlinks-for snipname
	;display snipname
	http-redir rejoin [ vanilla-base-url vanilla-display-url snipname ]
	]

display-common-procedure: func [snipname] [
	; displays++
	; .name into internal-snips
	; metadata into internal-snips
	; has nothing to do with presentation layer

	if (space-meta-get snipname "displays") = none [space-meta-set snipname "displays" 0]
	space-meta-set snipname "displays" ((space-meta-get snipname "displays") + 1)

	insert internal-snips snipname
	insert internal-snips ".name"

	metadata: space-meta-get-all snipname
	forskip metadata 2 [one: metadata/1 remove metadata insert metadata rejoin ["." one]]
	metadata: head metadata

	insert internal-snips metadata
	]


display: func [snipname /local snip] [
	display-common-procedure snipname
	html-snip: space-expand replace space-get "vanilla-template" "[snip-content]" html-format space-expand space-get snipname
	print htmlheader
	print html-snip
	]

display-text: func [snipname /local snip] [
	display-common-procedure snipname
	html-snip: html-format space-expand space-get snipname
	print htmlheader
	print html-snip
	]

display-raw: func [snipname /local snip] [
	display-common-procedure snipname
	raw-snip: space-get snipname
	print htmlheader
	print raw-snip
	]

eval-p: func [mode class request-class snip] [
	always-visible-snips: ["vanilla-user-register" "vanilla-user-register-do" "vanilla-user-login" "vanilla-user-logged-out" "vanilla-user-login-failure"]
	if = class 'edit [always-visible-snips: []]
	return ((= vanilla-space-mode mode) and (= class request-class) and (= none find always-visible-snips snip))
	]

permissions-ok?: func [class snip /local always-visible-snips] [
	if all [ (not = user none) (= "true" to-string (user/get 'disabled)) ]
		[display "vanilla-user-disabled" quit]
	if (eval-p "closed" 'display class snip) and (= user none) 
		[display "vanilla-please-login" quit]
	if (eval-p "closed" 'edit class snip) and (= user none) 
		[display "vanilla-please-login" quit]
	if (eval-p "closed" 'display class snip) and (not users-is-associate? user) 
		[display "vanilla-wait-for-association" quit]
	if (eval-p "closed" 'edit class snip) and (not users-is-associate? user) 
		[display "vanilla-wait-for-association" quit]
	if (eval-p "readonly" 'edit class snip) and (= user none) 
		[display "vanilla-please-login" quit]
	if (eval-p "readonly" 'edit class snip) and (not users-is-associate? user) 
		[either (not = user/get 'id space-meta-get snip "originator-id") [
		 	display "vanilla-editing-disallowed" quit
			] [
			]
		]
	if (eval-p "open" 'edit class snip) and (= user none) 
		[display "vanilla-please-login" quit]
	]

handle: func [params] [

	do params

	; if you want to limit vanilla functionality, remove the selector below
	valid-selectors: ["user-login" "user-logout" "end-session" "display" "display-text" "display-raw" "info" "edit" "new" "store"]

	either (find valid-selectors selector) = none
		[snip: "vanilla-no-such-selector" display snip]
		[switch selector [
			"display" [
				if error? try [snip] [snip: "start"]
				permissions-ok? 'display snip
				display snip
				]
			"info" [ 
				print textheader
				print "synerge vanilla/r (c) christian langreiter 2000-2001"
				print probe system/options
				]
			"display-text" [
				permissions-ok? 'display snip
				display-text snip
				]
			"display-raw" [
				permissions-ok? 'display snip
				display-raw snip
				]
			"display-js" [
				permissions-ok? 'display snip
				display-js snip
				]
			"edit" [
				permissions-ok? 'edit snip
				edit snip
				]
			"new" [
				permissions-ok? 'edit snip
				new snip
				]
			"store" [
				permissions-ok? 'edit snip
				store snip snip-content
				]
			"end-session" [
				if (sessions-valid? vanilla-session-id) [
					sessions-delete vanilla-session-id
					; print "Content-type: text/html^/^/deleted"
					http-redir rejoin [vanilla-html-link-prefix script-name "?selector=display&snip=start"]
					quit
					]
				]
			"user-login" [
				; print htmlheader
				either (users-valid-name-and-passphrase? user-name passphrase) [
					if (not = (to-string (session/get 'associated-user-id)) "none") [
						sessions-delete vanilla-session-id
						set-cookie "vanilla-user-id" "-1/invalidated" "/" "0"
						sessions-collect
						http-redir rejoin [vanilla-html-link-prefix script-name "?selector=user-login&user-name=" user-name "&passphrase=" passphrase]
						]
					user: users-get-by-name user-name
					set-cookie "vanilla-preburner" "xxx-rated" "/" " "
					set-cookie "vanilla-user-id" rejoin [user/get 'id "/" user/get 'valikey] "/" "13-Sep-2079 11:43:00 GMT"
					session/set 'associated-user-id (user/get 'id)
					sessions-store vanilla-session-id session
					if error? try [redirect-to] [redirect-to: "vanilla-user-login-success"]
					if (length? redirect-to) < 2 [redirect-to: "vanilla-user-login-success"]
					; print htmlheader print "Chokemun!"
					if (       (= redirect-to "vanilla-user-logged-out") 
						or (= redirect-to "vanilla-user-login-failure")
						) [redirect-to: "start"]
					http-redir rejoin [vanilla-html-link-prefix script-name "?selector=display&snip=" redirect-to]
					] [
					set-cookie "vanilla-user-id" "-1/invalidated" "/" " "
					http-redir rejoin [vanilla-html-link-prefix script-name "?selector=display&snip=vanilla-user-login-failure"]
					]
				sessions-collect
				quit
				]
			"user-logout" [
				sessions-delete vanilla-session-id
				set-cookie "vanilla-user-id" "-1/invalidated" "/" " "
				http-redir rejoin [vanilla-html-link-prefix script-name "?selector=display&snip=vanilla-user-logged-out"]
				quit
				]
			]
		]
	]

vanilla-space-mode: space-meta-get "vanilla-options" "space-mode"

vanilla-session-id: get-cookie "vanilla-session-id"
vanilla-user-id-cookie: get-cookie "vanilla-user-id"

vanilla-user-id-cookie: parse to-string vanilla-user-id-cookie "/"

either not = (length? vanilla-user-id-cookie) 2
	[user: none]
	[vanilla-user-id:  vanilla-user-id-cookie/1
	 vanilla-user-key: vanilla-user-id-cookie/2
	 either users-valid-id-and-key? vanilla-user-id vanilla-user-key [
		user: users-get-by-id vanilla-user-id
		insert internal-snips vanilla-user-id
		insert internal-snips "vanilla-user-id"
		insert internal-snips (user/get 'name)
		insert internal-snips "vanilla-user-name"
		] [
		user: none
		set-cookie "vanilla-user-id" "-1/invalidated" "/" " "
		]
	]

either sessions-valid? vanilla-session-id [
	session: sessions-get vanilla-session-id
	either (user = none) [
		session/set 'associated-user-id none
		] [
		session/set 'associated-user-id user/get 'id
		]
	] [
	; if not = (find system/options/cgi/query-string vanilla-cookie-fail-phrase) none [print textheader print vanilla-cookie-enable-text quit]
	sessions-delete vanilla-session-id
	vanilla-session-id: sessions-generate-id
	sessions-create vanilla-session-id
	session: sessions-get vanilla-session-id
	session/set 'remote-ip system/options/cgi/remote-addr
	either (not = user none) [session/set 'associated-user-id user/get 'id] [session/set 'associated-user-id none]
	sessions-store vanilla-session-id session
	set-cookie "vanilla-session-id" vanilla-session-id "/" " " 
	]

if (= users-get-max -1) [
	either equal? params [] [snip: "vanilla-user-register-master"] [do params]
	if error? try [snip] [display "vanilla-user-register-master" quit]
	either (= snip "vanilla-user-register-do") [
		display "vanilla-user-register-do" quit
		] [
		display "vanilla-user-register-master" quit
		]
	]

sessions-collect

either equal? params [] [
	snip: "start" 
	permissions-ok? 'display snip 
	display snip quit
	] [
	handle params
	]

; print "<hr>"
; probe vanilla-space-mode
; print "<hr>"

; print join vanilla-session-id ": "
; probe session/data

; print "<hr>"
; probe vanilla-user-id-cookie
; either = user none [print "User not logged in."] [probe user/data]

sessions-store vanilla-session-id session
if (not = user none) [users-store user]

; print "<hr>"

sessions-collect

; print join "users online: " length? sessions-get-all-ids

quit

; vim: set nowrap syn=rebol:
