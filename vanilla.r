REBOL [
    Title:		
		"synerge vanilla/R"
    Authors:	
		[ "Christian Langreiter" "Andreas Bolka" ]
    Version:	
		0.6.2
	Date:
		2004-11-07

	Rights: {
		Copyright (C) 2000-2004 Andreas Bolka, Christian Langreiter
		Licensed under the Academic Free License version 2.0.
	}
]

; $Id: vanilla.r,v 1.10 2004/11/11 14:38:22 earl Exp $
; =============================================================================
;
; 2000-02-11 	0.0.1i	started as "prototypical vanilla rewrite in REBOL"
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
;						wml support removed (should be outsourced to a separate script)
;						session/user mgmt debugged and interface pushed forward
; 2000-11-26	-		user interface design
; 2000-11-27	-		further integration, adoption of vanillean standards (dynasnips, templates)
; 2000-11-29	-		general cleanup, dynasnip caching, fast-backlinks-on-store
; 2001-02-13	0.5a1	implemented permission system
; 2001-02-27	-		fixed trivial but annoying bug in session code (case: user valid, session not)
; 2001-03-01	0.5pa1	lots of little buglets fixed, first public alpha
; 2001-03-05	-		added redirect-to to user-login
; 2001-05-25	-		reactivated display-text and display-raw
;
; 2001-05-25   			earl: added originator attribute, incorporated /space/ changes
; 2001-05-28   			chl: new linking
; 2001-07-12			earl: changed 'display*' for enhanced security possibilities
; 2001-07-17			earl: store redirects to display-url
; 2001-07-17			chl: introduced lib
; 2001-08-25			chl: added really fast backlinks (finally!)
; 2001-08-30	0.5 	release (!!!), redirect-to exceptions
; 2001-10-??			earl: some minor bugfixes
; 2001-11-??			earl: POST rewrite
; 2001-11-22			chl: link up bugfix
; 2001-11-25			earl: edit + HTML bugfix
; 2001-12-03			earl: basic cookie bugfixing, should advance to Max-Age use
; 2001-12-07			earl: sysdata-recent-stores
; 2001-??-??	0.5.1	release
; 2002-03-31			earl: some url-enc bugfixes, incorporating some chl bugfixes
; 2002-04-05			earl: html-link-me-up is case sensitive (chl bugxi)
; 2002-04-19			earl: snip naming cleanup
; 2002-05-11			earl: major core rewrite: auth/user/session, main
; 2002-05-12			earl: further refactoring
; 2002-05-21			earl: added display-asis
; 2002-06-09			earl: backlink heuristics, various minor mods
; 2002-07-13			earl: 
;						- base-url usage with http-redir unified
;						- flexible-link-up bugs fixed (links containing // could not use post-colon)
;						- nifty cgi params parsing bug fixed (nams/vals was provided by get AND post)
;						- a multitude of small style-cleanups and typo's fixed
; 2002-07-28			earl: 
;						- internal-links-in? bug fixed (pre-colon related)
;						- added __config-loaded flag
; 2002-10-08			earl: fixed delete snip functionality
; 2003-04-02			earl: display selector: improved template handling, removed redundancies
; 2003-04-03			earl: small param parsing fixes, post-data is preserved in global __post-data
; 2003-04-04			earl: heuristics bug fixed
; 2003-07-08			earl:
;						- copyright changed to 2003 (info selector)
;						- incorporated chris' configurable start snip (vanilla-start-snip) modification
; 2003-07-14			earl: resource-url internal snip added (-> {resource-url})
; 2003-07-21			earl: all set-cookie calls w/o expire-date now use "" instead of " " [thx rist]
; 2003-07-27			earl: fixed a 'parse related heuristics bug. added string-tools lib
; 2003-08-24			earl: case insensitivity bug in delete selector
; 2003-09-01			earl: fixed some start-snip bugs
; 2003-09-02			earl:
;						- cookie-prefix stuff
;							- removed set-cookie-then-redirect (never used)
;							- added vanilla-cookie-prefix config param
;							- added /unprefixed refinement to get/set-cookie
;						- almost all legacy code-layout cleaned
;						- url generation configuration handling improved
; 2003-09-03			earl: version numbers updated to 0.5.4
; 2003-09-14			earl: slight improvement of http-redir
; 2003-09-16			earl: bugfix in flexible-link-up 
; 2003-09-22			earl: minor release cleanups
; 2003-12-24			earl: 
;						- removed vanilla-html-link-prefix
;						- prepared for release as 0.6.0
; 2004-01-08			prepared 0.6.1
; 2004-05-07			earl: incorporated set-cookie param reordering (thanks Luke!)
; 2004-07-03			earl:
;						- added first-store-date meta
;						- removed dns lookup for last-store-addr meta
; 2004-07-07			earl: added sniptag support
; 2004-11-07			prepared 0.6.2
; 2004-11-11			fixed cookie bug introduced by "lynx fix"
;
; =============================================================================


if all [ not error? try [ __config-loaded ] (value? 'benchmark) benchmark ] [ __t0: now/time/precise ]

; print "Content-type: text/html^/^/"
; trace true
; print system/options/cgi/content-length


; --- cgi stuff ---

; cgi-param fetching is now on the top i.o. to prevent too easy 
; exploits (variable overwriting)

params: copy []
; get
append params decode-cgi any [ system/options/cgi/query-string "" ]
; post
if system/options/cgi/request-method = "POST" [
	len: load any [ system/options/cgi/content-length "0" ]
	__post-data: make string! ( len + 10 )
	while [ 0 < read-io system/ports/input __post-data len ] []
	if tmp: attempt [ decode-cgi __post-data ] 
		[ append params tmp ]
	; append params decode-multipart-form-data/fallback __post-data
]      

; --- utility functions ---

http-redir: func [ url ] [
	; print htmlheader
	; print "I should go. Go yourself!"
    print rejoin [
        "Status: 302 Moved temporarily" newline
        "Location: " url newline
    ]
	quit
]

get-cookies-raw: func [] [
	select system/options/cgi/other-headers "HTTP_COOKIE"
]

get-cookie: func [ name /unprefixed ] [
	; if called w/o /unprefixed refinement then prefix!
	if none? unprefixed [ insert name vanilla-cookie-prefix ]

	if none? get-cookies-raw [ return none ]
	select (parse get-cookies-raw "; =") name
]

set-cookie: func [ key value path expires /unprefixed /local s ] [
	; if called w/o /unprefixed refinement then prefix!
	if none? unprefixed [ insert key vanilla-cookie-prefix ]

	s: rejoin [ "Set-Cookie: " key "=" value "; " ]
	if not empty? expires [
		append s rejoin [ "expires=" expires "; " ]
	]
	append s rejoin [ "path=" path ";" ]

	print s
]

textheader:	"Content-Type: text/plain^/"
htmlheader:	"Content-Type: text/html^/"

; --- internal vanilla startup (config, libs/plugins) ---

set-default: func [ 
    {Sets a word to the specified default-value iff the word
    is not set already.}
    word
    default-value
] [ 
    if unset? get/any word [ set word default-value ] 
]

sys-script-name: system/options/script
script-name: last parse sys-script-name "/"

; load config
if error? try [ __config-loaded ] [ 
	do load to-file join script-name ".conf" 
]

; load internal libs
do load to-file join lib-dir "secure-hash.r"
do load to-file join lib-dir "simplemeta.r"

; load pluggable libs
do load to-file rejoin [ lib-dir space-accessor ".r" ]
do load to-file rejoin [ lib-dir userdb-accessor ".r" ]
do load to-file rejoin [ lib-dir sessiondb-accessor ".r" ]

; set default config vals
set-default	'vanilla-cookie-prefix	copy ""
set-default	'vanilla-start-snip		copy "start"

set-default 'vanilla-base-url		copy ""

set-default 'vanilla-get-url		rejoin [ vanilla-base-url script-name ]
set-default 'vanilla-post-url		rejoin [ vanilla-base-url script-name ]

set-default 'vanilla-display-url	rejoin [ vanilla-get-url "?selector=display&snip="	]
set-default 'vanilla-edit-url		rejoin [ vanilla-get-url "?selector=edit&snip="		]
set-default 'vanilla-new-url		rejoin [ vanilla-get-url "?selector=new&snip="		]
set-default 'vanilla-store-url		rejoin [ vanilla-get-url "?selector=store&snip="	]

; internal snips are found first by the space-expand function (access them directly by eg {now})
; ".xxx" snips are metadata attributes of a snip (like .name, .author, etc.)

internal-snips: reduce [
	"script-version"		0.6.2
	"script-name"			script-name
	"now"					now
	"space-id"				vanilla-space-identifier
	"resource-dir"			resource-dir
	"resource-url"			resource-url

	"vanilla-base-url"		vanilla-base-url

	"vanilla-get-url" 		vanilla-get-url
	"vanilla-post-url" 		vanilla-post-url

	"vanilla-display-url" 	vanilla-display-url
	"vanilla-edit-url" 		vanilla-edit-url
	"vanilla-store-url" 	vanilla-store-url
	"vanilla-new-url" 		vanilla-new-url
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

html-format-links: func [snip /local link-rule link] [
	;vanilla-link-rules: to-block space-expand space-get "vanilla-links"
	link-rule: [thru "*" copy link to "*"]
	forever [
		link: none
		parse snip link-rule
		either link = none
			[return snip]
			[snip: html-link-me-up snip link]
	]
]

is-internal-link?: func [link /local rules found ] [
	if none? link [ return false ]
	; attention: has to be in sync with flexible-link-up
	rules: to-block space-expand space-get "vanilla-links"
	pre-colon: none
	parse link [ copy pre-colon to ":" to end ]
	found: find rules pre-colon
	; hmmm, have to think about pre-snip-existence-creation of metadata/fast-backlinks ...
	; either (= found none) [either space-exists? link [return true] [return false]] [return false]
	either found? find rules pre-colon [ return false ] [ return true ]
]

flexible-link-up: func [str /local html-str full pre-colon post-colon post-slashes rules rule found ] [
    rules: to-block space-expand space-get "vanilla-links"

    parse str [ copy pre-colon to ":" thru ":" copy post-colon to end ]
    if post-colon [ parse post-colon [ thru "//" copy post-slashes to end ] ]

    found: find rules pre-colon
    either none? found [
        ; @@ html-encode
        html-str: replace/all copy str "&" "&amp;"
        either space-exists? str
            [ return rejoin [ {<a href="} vanilla-display-url url-encode str {">} html-str {</a>} ] ]
            [ return rejoin [ {[create <a href="} vanilla-new-url url-encode str {">} html-str {</a>]} ] ]
    ] [
        rule: copy first next found
        replace/all rule 'full str
        replace/all rule 'pre-colon any [ pre-colon "" ]
        replace/all rule 'post-colon any [ post-colon "" ]
        replace/all rule 'post-slashes any [ post-slashes "" ]
        replace/all rule 'url-encoded-post-colon url-encode any [ post-colon "" ]

        return rejoin rule
    ]
]

html-link-me-up: func [snip link] [
	replace/all snip "%2F" "/"
	replace/all/case snip rejoin ["*" link "*"] flexible-link-up link
	return snip
]

html-format-bold: func [snip] [
	span-rule: [thru "__" copy span to "__"]
	forever [
		span: none
		parse snip span-rule
		either span = none
			[return snip]
			[replace snip rejoin ["__" span "__"] rejoin ["<b>" span "</b>"]]
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

html-escape-newlines: func [snip] [
	snip: replace/all snip (esc-to-meta join "\" newline) ""
	snip: replace/all snip (esc-to-meta join "\" crlf) ""
	snip: replace/all snip (esc-to-meta join "\" cr) ""
	snip
]

html-format: func [snip] [
	snip: esc-to-meta snip
	snip: html-escape-newlines snip

	snip: html-format-breaks snip
	snip: html-format-links snip
	snip: html-format-bold snip
	snip: html-fixup-umlauts snip

	snip: meta-to-esc snip
	snip
]

; --- pre-cached backlink generation functions ---
; --- super-fast edition, chl 2001-05-25 ---

internal-links-in: func [snip-data /local links e r] [
	links: copy [] r: copy []
	snip-data: esc-to-meta snip-data
	parse snip-data [ any [ thru "*" copy text to "*" skip (append links text) ] ]
	foreach e links 
		[ if is-internal-link? e [append r e] ]

	r
]

snip-content-heuristically-ok?: func [ snip /local sdata ct tmp ] [
	odd? length? split (esc-to-meta space-get snip) "*"
]

link-heuristically-ok?: func [ sniplink ] [
	all [ 
		((length? sniplink) < 40)
	]
]

modify-backlinks: func [for-snip snip-name f /local old-backlinks] [
	old-backlinks: copy any [ (space-meta-get for-snip "fast-backlinks") [] ]
	if any [
		(space-exists? for-snip)
		all [
			(snip-content-heuristically-ok? snip-name)
			(link-heuristically-ok? snip-name)
			(link-heuristically-ok? for-snip)
			(not found? find snip-name "*")
		]
	] [ 
		space-meta-set for-snip "fast-backlinks" f old-backlinks to-block mold snip-name 
	]
]

purge-backlinks-for: func [snip-name /local backlinking-snip] [
	foreach backlinking-snip (internal-links-in space-get snip-name) 
		[ modify-backlinks backlinking-snip snip-name :exclude ]
]

create-backlinks-for: func [snip-name /local snip-to-backlink] [
	foreach snip-to-backlink (internal-links-in space-get snip-name) 
		[ modify-backlinks snip-to-backlink snip-name :union ]
]

; --- handler functions ---

new: func [snipname] [
	edit snipname
	]

edit: func [snipname /local htmlname snip edit-ct edit-form] [
	repend internal-snips [ ".name" snipname ]
	repend internal-snips [ ".url-name" (url-encode snipname) ]

	; @@ html-encode
	htmlname: copy snipname
	replace/all htmlname "&" "&amp;"
	replace/all htmlname "^"" "&quot;"
	replace/all htmlname "^'" "&#39;"
	repend internal-snips [ ".html-name" htmlname ]

	print htmlheader
	edit-ct: space-get snipname
	replace/all edit-ct "&" "&amp;"
	replace/all edit-ct "<" "&lt;"
	replace/all edit-ct ">" "&gt;"

	edit-form: space-expand space-get "vanilla-edit-form-template"
	replace/all edit-form "[snip-content-for-editing]" rejoin [ newline edit-ct ]
	replace/all edit-form "[snip-tags]" any [ (space-meta-get snipname "tags") (copy "") ]

	print replace (space-expand space-get "vanilla-template") "[snip-content]" edit-form 
]

store-raw: func [snipname snipdata /local resolved-remote snip-at-hand uid t0] [
	t0: now

	replace/all snipdata crlf newline
	space-store snipname snipdata

	space-meta-set snipname "last-store-date" t0
	space-meta-set snipname "last-store-addr" system/options/cgi/remote-addr

	; first-store-date
	if none? space-meta-get snipname "first-store-date"
		[ space-meta-set snipname "first-store-date" t0 ]

	uid: either (not = none user) [ user/get 'id ] [ none ] 
	; last-editor
	space-meta-set snipname "last-editor-id" uid
	; originator 
	if none? (space-meta-get snipname "originator-id") 
		[ space-meta-set snipname "originator-id" uid ]

	if none? (space-meta-get snipname "displays")
		[ space-meta-set snipname "displays" 0 ] 
]

update-recent-stores: func [ snipname ] [
	odb: "sysdata-recent-stores"
	roll-limit: 100
	
	if not space-exists? odb [ space-store odb mold [] ]

	l: load space-get odb
	insert l snipname ; reduce [ snipname (space-meta-get-all snipname) ]
	l: unique/case l
	l: copy/part l roll-limit ; (roll-limit * 2)
	space-store odb mold l
]

store: func [snipname snipdata sniptags] [
	if = snipname "" [ http-redir rejoin [ vanilla-display-url "vanilla-store-error" ] ]
	purge-backlinks-for snipname
	store-raw snipname snipdata
	create-backlinks-for snipname
	space-meta-set snipname "tags" sniptags

	update-recent-stores snipname

	;display snipname
	http-redir rejoin [ vanilla-display-url url-encode snipname ]
]

delete-snip: func [ snipname ] [
	purge-backlinks-for snipname
	either space-delete snipname [
		if space-exists? "sysdata-recent-stores" [
			odb: load space-get "sysdata-recent-stores"
			odb: exclude/case odb reduce [ snipname ]
			space-store "sysdata-recent-stores" mold odb
		]

		http-redir rejoin [ vanilla-display-url "vanilla-delete-ok&snip-ex=" snipname ]
	] [
		http-redir rejoin [ vanilla-display-url "vanilla-delete-error&snip-ex=" snipname ] 
	]
]


display-common-procedure: func [snipname /local metadata] [
	; displays++
	; .name into internal-snips
	; metadata into internal-snips
	; has nothing to do with presentation layer

	if (space-meta-get snipname "displays") = none [space-meta-set snipname "displays" 0]
	space-meta-set snipname "displays" ((space-meta-get snipname "displays") + 1)

	repend internal-snips [ ".name" snipname ]
	repend internal-snips [ ".url-name" (url-encode snipname) ]
	; @@ html-encode
	htmlname: copy snipname
	replace/all htmlname "&" "&amp;"
	replace/all htmlname "^"" "&quot;"
	replace/all htmlname "^'" "&#39;"
	repend internal-snips [ ".html-name" htmlname ]

	metadata: space-meta-get-all snipname
	forskip metadata 2 
		[ repend internal-snips [ (join "." metadata/1) metadata/2 ] ]
]

display: func [snipname /local html-snip] [
	display-common-procedure snipname
	html-snip:
		meta-to-html 
			replace 
				esc-to-meta space-expand esc-to-meta space-get "vanilla-template" 
				"[snip-content]" 
				esc-to-meta html-format space-expand esc-to-meta space-get snipname
	print htmlheader
	print html-snip
]

display-text: func [snipname /local html-snip] [
	display-common-procedure snipname
	html-snip: esc-to-html html-format space-expand esc-to-meta space-get snipname
	print htmlheader
	print html-snip
]

display-raw: func [snipname /local raw-snip] [
	display-common-procedure snipname
	raw-snip: space-get snipname
	print htmlheader
	print raw-snip
]

display-asis: func [snipname] [
	display-common-procedure snipname
	print space-expand space-get snipname
]

eval-p: func [mode class request-class snip /local always-visible-snips] [
	always-visible-snips: [
		"vanilla-user-register" "vanilla-user-register-do" 
		"vanilla-user-login" "vanilla-user-logged-out" "vanilla-user-login-failure"
	]
	if = class 'edit [always-visible-snips: []]
	return ((= vanilla-space-mode mode) and (= class request-class) and (= none find always-visible-snips snip))
]

permissions-ok?: func [class snip /local always-visible-snips] [
	if all [ (not = user none) (= "true" to-string (user/get 'disabled)) ]
		[display "vanilla-user-disabled" quit]
	if (eval-p "closed" 'display class snip) and (= user none) 
		[display "vanilla-user-please-login" quit]
	if (eval-p "closed" 'edit class snip) and (= user none) 
		[display "vanilla-user-please-login" quit]
	if (eval-p "closed" 'display class snip) and (not users-is-associate? user) 
		[display "vanilla-user-wait-for-association" quit]
	if (eval-p "closed" 'edit class snip) and (not users-is-associate? user) 
		[display "vanilla-user-wait-for-association" quit]
	if (eval-p "readonly" 'edit class snip) and (= user none) 
		[display "vanilla-user-please-login" quit]
	if (eval-p "readonly" 'edit class snip) and (not users-is-associate? user) 
		[ either (not = user/get 'id space-meta-get snip "originator-id") 
			[ display "vanilla-user-editing-disallowed" quit ] 
			[ ] ]
	if (eval-p "open" 'edit class snip) and (= user none) 
		[display "vanilla-user-please-login" quit]
]

handle: func [params] [

	; bind supplied url-params to global rebol words
	do params

	; if you want to limit vanilla functionality, remove the selector below
	valid-selectors: [ 
		"user-login" "user-logout" "end-session" 
		"display" "display-text" "display-raw" "display-asis" 
		"info" "edit" "new" "store" "delete"
	]

	either (find valid-selectors selector) = none
		[ snip: "vanilla-no-such-selector" display snip ]
		[ switch selector [
			"display" [
				snip: any [ attempt [ snip ] vanilla-start-snip ]
				permissions-ok? 'display snip
				display snip
				]
			"info" [ 
				print textheader
				print "synerge vanilla/r"
				print "Copyright (C) 2000-2004 by Andreas Bolka, Christian Langreiter"
				print mold system/options/cgi
				]
			"display-text" [
				permissions-ok? 'display snip
				display-text snip
				]
			"display-raw" [
				permissions-ok? 'display snip
				display-raw snip
				]
			"display-asis" [
				permissions-ok? 'display snip
				display-asis snip
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
				store snip snip-content snip-tags
				]
			"delete" [
				permissions-ok? 'edit snip
				delete-snip snip
				]
			"end-session" [
				if (sessions-valid? vanilla-session-id) [
					sessions-delete vanilla-session-id
					; print "Content-type: text/html^/^/deleted"
					http-redir rejoin [ vanilla-display-url vanilla-start-snip ]
					quit
				]
				] ; end-session
			"user-login" [
				; expected parameters: user-name and passphrase

				either not users-valid-name-and-passphrase? user-name passphrase [
					http-redir rejoin [ vanilla-display-url "vanilla-user-login-failure" ]
					quit ; never reached as http-redir 'quits
				] [
					; user wants to login:
					; if he alreay has a session and the session has an user associated
					; do not simply reuse that session but create a new one instead
					; we will just invalidate the old session, by that we force that the 
					; new session will be created after the final redirect
					if not none? user [ sessions-delete vanilla-session-id ]

					; set user cookie
					user: users-get-by-name user-name
					set-cookie 
						"vanilla-uid" rejoin [ (user/get 'id) "/" (user/get 'valikey) ]
						"/" "Thu, 11-Dec-2031 11:42:00 GMT"

					; now let's go for the final redirection ;)
					if error? try [ redirect-to ] [ redirect-to: "vanilla-user-login-success" ]
					redirect-to-blacklist: [
						""
						"vanilla-user-logged-out"
						"vanilla-user-login-failure"
						"vanilla-user-please-login"
					] 
					if find redirect-to-blacklist redirect-to [ redirect-to: vanilla-start-snip ]

					http-redir rejoin [ vanilla-display-url redirect-to ]
					quit ; never reached as http-redir 'quits
				]
				] ; user-login

			"user-logout" [
				sessions-delete vanilla-session-id
				set-cookie "vanilla-uid" "" "/" ""
				http-redir rejoin [ vanilla-display-url "vanilla-user-logged-out"]
				quit ; never reached as http-redir 'quits
				]
			]
		]
	]

init-vanilla-user: has [ userid valikey ] [ 
	user: none

	if not all [
		(cookie: get-cookie "vanilla-uid")
		(cookie: parse cookie "/")
		(= length? cookie 2)
		(set [ userid valikey ] cookie)
		(users-valid-id-and-key? userid valikey)
	] [ 
		; we received an invalid cookie. we do not want to get
		; that again, so we invalidate the cookie
		set-cookie "vanilla-uid" "" "/" ""
		return
	]

	user: users-get-by-id cookie/1
	repend internal-snips [ 
		"vanilla-user-id" userid 
		"vanilla-user-name" (user/get 'name)
	]
]

init-vanilla-session: has [ vanilla-sid-cookie ] [
	session: none

	vanilla-sid-cookie: get-cookie "vanilla-sid"
	vanilla-session-id: vanilla-sid-cookie

	either sessions-valid? vanilla-session-id [
		session: sessions-get vanilla-session-id
		either (user = none) 
			[ session/set 'associated-user-id none ] 
			[ session/set 'associated-user-id user/get 'id ]
	] [
		sessions-delete vanilla-session-id

		vanilla-session-id: sessions-generate-id
		session: sessions-create vanilla-session-id
		session/set 'remote-ip system/options/cgi/remote-addr
		either not none? user 
			[ session/set 'associated-user-id user/get 'id ] 
			[ session/set 'associated-user-id none ]

		sessions-store vanilla-session-id session

		set-cookie "vanilla-sid" vanilla-session-id "/" "" 
	]
]

main: does [
	; 'globals'
	user: session: none 
	vanilla-session-id: none
	vanilla-space-mode: space-meta-get "vanilla-options" "space-mode"

	; create user and session from the cookies (eventually) supplied
	init-vanilla-user
	init-vanilla-session

	; if no user was ever created before, pave the way for your master!
	if = users-get-max -1 [ 
		do params
		if any [ 
			(error? try [ snip ]) 
			(not = snip "vanilla-user-register-do") 
		] [ snip: "vanilla-user-register-master" ]

		display snip return 
	]

	; go and harvest those timeouting sessions!
	sessions-collect

	; now serve your client!
	either empty? params [
		snip: copy vanilla-start-snip
		permissions-ok? 'display snip
		display snip
	] [
		handle params
	]

	; cleanup & persist
	sessions-store vanilla-session-id session
	if (not = user none) [users-store user]
]

;; load patches

do load to-file rejoin [ lib-dir "etc/" %string-tools.r ]
do load to-file rejoin [ lib-dir "etc/" %decode-cgi.r ]

main

if all [ not error? try [ __config-loaded ] (value? 'benchmark) benchmark ] [ 
	__t1: now/time/precise 
	print rejoin [ "<code> " __t1 - __t0 " </code>" ]
]

; vim: set syn=rebol ts=4 sw=4:
