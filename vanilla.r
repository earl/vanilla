#!c:/win95/desktop/rebol/rebol.exe -cs
;#!/home/clangreit/rebol -cs
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

REBOL [
    Title:  "synerge vanilla/r"
    File: %vanilla.r
    Author: "Christian Langreiter"
    Version: 0.3.6
]

; --- cgi-param fetching is now on the top i.o. to prevent too easy exploits ---

params: decode-cgi system/options/cgi/query-string ; GET

grandebuf: make string! 4096
while [not = buf: copy/part system/ports/input 4096 []] [
	append grandebuf buf
	]

insert params decode-cgi grandebuf

; --- fetchismo finito! ---

; --- utility functions ---

http-redir: func [url] [
	print join "Location: " url
	print join "Expires: 0" newline
	]

replace: func [
    {Replaces the search value with the replace value within the target series.}
    target [series!] "Series that is being modified."
    search "Value to be replaced."
    replace "Value to replace with."
    /all "Replace all occurrences."
    /local save-target len
][
    save-target: target
    if (any-string? target) and (not any-string? :search) [search: form :search]
    len: either any [any-string? target any-block? :search] [length? :search] [1]
    while [target: find/case target :search] [
        target: change/part target :replace len
        if not all [break]
    ]
    save-target
]

textheader: 	"Content-Type: text/plain^/"
htmlheader: 	"Content-Type: text/html^/"
jsheader: 	"Content-type: script/javascript^/"

wmlheader:	"Content-type: text/vnd.wap.wml^/"
wmlprologue:	join
		{<?xml version="1.0"?>^/}
		{<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.1//EN" "http://www.wapforum.org/DTD/wml_1.1.xml">^/}

; print htmlheader

; configuration file is loaded and exec'd (it's written in REBOL)

sys-script-name: system/options/script
script-name: pick parse sys-script-name "/" length? parse sys-script-name "/"

; --- some things which might be in the .conf (or not) ---

vanilla-html-link-prefix: "" ; might be reset in the .conf
vanilla-wml-link-prefix: "" ; ditto

; --- load .conf & space accessor

do load to-file join script-name ".conf"
do load to-file join space-accessor ".r"

; internal snips are found first by the space-expand function
; ".xxx" snips are metadata attributes of a snip (like .name, .author, .date-last-edit etc.)

internal-snips: [
	"script-version"	0.3.6
	"script-name"		script-name
	"now"			now
	]

; --- vanilla misc vars / funcs ---

to-vanilla-date: func [date [date!] /local vdm vdd] [
	either (length? to-string date/month) = 1 [vdm: rejoin ["0" date/month]] [vdm: date/month]
	either (length? to-string date/day) = 1 [vdd: rejoin ["0" date/day]] [vdd: date/day]
	return rejoin [date/year "-" vdm "-" vdd]
	]

vanilla-date: to-vanilla-date now

vanilla-edit-url: rejoin [script-name "?selector=edit&snip="]

; --- html formatting functions ---

html-format-paragraphs: func [snip] [
	replace/all snip "^/^/" "<p>"
	snip
	]

html-format-breaks: func [snip] [
	replace/all snip "^/" "<br>"
	snip
	]

html-format-headlines: func [snip] [snip]

html-link-me-up: func [snip link] [
; --- http links ---
	part: copy/part link 7
	if = part "http://" [
		replace snip
			rejoin ["*" link "*"]
			rejoin ["<a href=" link ">" link </a>]
		return snip
		]
; --- ftp links ---
	part: copy/part link 6
	if = part "ftp://" [
		replace snip
			rejoin ["*" link "*"]
			rejoin ["<a href=" link ">" link </a>]
		return snip
		]
; --- mailto links ---
	part: copy/part link 7
	if = part "mailto:" [
		replace snip
			rejoin ["*" link "*"]
			rejoin ["<a href=" link ">" link </a>]
		return snip
		]
; --- AltaVista links ---
	part: copy/part link 3
	if = part "av:" [
		replace snip
			rejoin ["*" link "*"]
			rejoin ["<a href=http://www.altavista.com?q=" url-encode skip link 3 ">" "Search Altavista for " skip link 3 </a>]
		return snip
		]
; --- standard vanilla links ---
	either space-exists? link
		[replace snip
			rejoin ["*" link "*"]
			rejoin ["<a href=" vanilla-html-link-prefix script-name "?selector=display&snip=" url-encode link ">" link </a>]
			]
		[replace snip
			rejoin ["*" link "*"]
			rejoin ["[create <a href=" vanilla-html-link-prefix script-name "?selector=new&snip=" url-encode link ">" link </a> "]"]
			]		
	return snip
	]

html-format-links: func [snip] [
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

html-format-italic: func [snip] [snip]

html-format-list: func [snip] [snip]

html-fixup-umlauts: func [snip] [
	replace/all snip "ä" "&auml;"
	replace/all snip "ö" "&ouml;"
	replace/all snip "ü" "&uuml;"
	replace/all snip "Ä" "&Auml;"
	replace/all snip "Ö" "&Ouml;"
	replace/all snip "Ü" "&Uuml;"
	return snip
	]

html-format: func [snip] [
	snip: html-format-breaks snip
	snip: html-format-paragraphs snip
	snip: html-format-headlines snip
	snip: html-format-links snip
	snip: html-format-bold snip
	snip: html-format-italic snip
	snip: html-format-list snip
	snip: html-fixup-umlauts snip
	snip
	]

; --- wml formatting functions ---

wml-link-me-up: func [snip link] [
; --- http links ---
	part: copy/part link 7
	if = part "http://" [
		replace snip
			rejoin ["*" link "*"]
			rejoin [{<a href="} link {">} link </a>]
		return snip
		]
; --- standard vanilla links ---
	either space-exists? link
		[replace snip
			rejoin ["*" link "*"]
			rejoin [{<a href="} vanilla-wml-link-prefix script-name {?selector=display-wml&snip=} url-encode link {">} link </a>]
			]
		[replace snip
			rejoin ["*" link "*"]
			rejoin ["[" link " doesn't exist]"]
			]		
	return snip
	]

wml-format-links: func [snip] [
	link-rule: [thru "*" copy link to "*"]
	link: none
	forever [
		parse snip link-rule
		either link = none
			[return snip]
			[snip: wml-link-me-up snip link]
		link: none
		]
	]

wml-format-breaks: func [snip] [
	replace/all snip "^/" "<br/>"
	snip
	]

wml-fixup-amps: func [snip] [
	replace/all snip "&" "&amp;"
	return snip
	]

wml-format: func [snip] [
	snip: wml-format-breaks snip
	snip: html-format-bold snip
	snip: wml-format-links snip
	snip: wml-fixup-amps snip
	snip
	]

; --- handler functions ---

new: func [snipname] [
	insert internal-snips snipname
	insert internal-snips ".name"
	print htmlheader
	print space-expand read to-file rejoin [resource-dir "styles/" style-name "-site-header-edit.txt"]
	prin {<form method=POST action="}
	prin script-name
	prin {">
 	      <input type="hidden" name="selector" value="store">
 	      snip title:<br>
              <input name="snip" size = "40" value = "}
	prin snipname
	prin {"><br>
 	      content:<br>
              <textarea name="snip_content" rows="16" cols="80" wrap="soft">}
	prin {</textarea><br><br>
 	      <input type="submit" value="Store in VanillaSpace">
	      </form>}
	print space-expand read to-file rejoin [resource-dir "styles/" style-name "-site-footer-edit.txt"]
	]

edit: func [snipname] [
	insert internal-snips snipname
	insert internal-snips ".name"
	print htmlheader
	print space-expand read to-file rejoin [resource-dir "styles/" style-name "-site-header-edit.txt"]
	snip: space-get snipname
	prin {<form method=POST action="}
	prin script-name
	prin {">
 	      <input type="hidden" name="selector" value="store">
 	      snip title:<br>
              <input name="snip" size = "40" value = "}
	prin snipname
	prin {"><br>
 	      content:<br>
              <textarea name="snip_content" rows="16" cols="80" wrap="soft">}
	prin snip
	prin {</textarea><br><br>
 	      <input type="submit" value="Store in VanillaSpace">
	      </form>}
	print space-expand read to-file rejoin [resource-dir "styles/" style-name "-site-footer-edit.txt"]
	]

store: func [snipname snipdata /local recent-edits resolved-remote snip-at-hand] [
	replace/all snipdata "^M^/" "^/"
	space-store snipname snipdata

	resolved-remote: read to-url rejoin ["dns://" system/options/cgi/remote-addr]

	space-meta-set snipname "last-store-time" now/time
	space-meta-set snipname "last-store-date" now/date
	space-meta-set snipname "last-store-addr" resolved-remote

	if (space-meta-get snipname "displays") = none [space-meta-set snipname "displays" 0]

	display snipname
	]

display-text: func [snipname] [
	
	print textheader

	snip: space-get snipname
	snip: space-expand snip
	print snip
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

display: func [snipname] [
	display-common-procedure snipname

	print htmlheader

	print space-expand read to-file rejoin [resource-dir "styles/" style-name "-site-header.txt"]
	snip: space-get snipname
	snip: space-expand snip
	html-format snip
	print snip
	print space-expand read to-file rejoin [resource-dir "styles/" style-name "-site-footer.txt"]
	]

display-raw: func [snipname] [
	display-common-procedure snipname

	print htmlheader

	snip: space-get snipname
	snip: space-expand snip
	html-format snip
	print snip
	]

display-js: func [snipname] [
	display-common-procedure snipname

	print jsheader

	snip: space-get snipname
	snip: space-expand snip
	html-format snip
	
	replace/all snip "'" "&#39;"
	
	prin {document.write('}
	prin snip
	print {');}
	]

display-wml: func [snipname] [
	; 2000-05-02
	display-common-procedure snipname
	
	print wmlheader

	print wmlprologue

	print "<wml>"
	print rejoin [{<card id="sng" title="} snipname {">}]
	print {<p>}

	snip: space-get snipname
	snip: space-expand snip
	snip: wml-format snip

	print snip

	print "</p>"
	print "</card>"

	print "</wml>"
	]

handle: func [params] [
	
	do params

	; if you want to limit vanilla functionality, remove the selector below
	valid-selectors: ["display" "display-text" "display-raw" "display-js" "display-wml" "info" "edit" "new" "store"]

	either (find valid-selectors selector) = none
		[display "vanilla-no-such-selector"]
		[switch selector [
			"display" [
				display snip
				]
			"info" [ 
				print textheader
				print "synerge vanilla (c) christian langreiter 2000"
				print probe system/options
				]
			"display-text" [
				display-text snip
				]
			"display-raw" [
				display-raw snip
				]
			"display-js" [
				display-js snip
				]
			"display-wml" [
				display-wml snip
				]
			"edit" [
				edit snip
				]
			"new" [
				new snip
				]
			"store" [
				store snip snip_content
				]
			]
		]
	]

; --- here the action really starts ---

if (= (copy/part system/options/cgi/query-string 3) "wml") [display-wml "start-wml" quit]
if equal? params [] [display "start" quit]
handle params quit
