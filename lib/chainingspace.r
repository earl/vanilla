REBOL []
; CVS: $Id: chainingspace.r,v 1.1 2003/09/22 21:46:03 earl Exp $
;
; 2002-04-16	earl
;		* created chainingspace as a fork from simplespace with space-chaining support
; 2002-04-28	earl
;		* dyna loader err msg bugfix (displays full package path)
; 2002-06-09	earl
;		* escaping modifications
; 2002-07-31	earl
;		* case handling bug fixed (unique/case in sys-dir)
; 2003-03-14	earl
;		* added system-snip? which returns true for sysdata-*/appdata-* and friends
;		* refactored space-dir to use system-snip?
; 2003-07-27	earl
;		* mods related to usage of string-tools lib

; required imports: space-params, app-dir

; --- simplespace-specific functions & variables

simplespace-info: "chaining file-based vanillaspace access module; 0.5.2 2002-04-16"

; --- utility functions
; url-encode by tomc@cs.uoregon.edu, merci

opt-in: charset " *-.1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"

url-encode: make function! [ str[string!] /re ] [ 
   if re [ insert  opt-in  "%:/&=" ]
   rslt: make string! ( (length? str ) * 3 )
   
   foreach  chr str [  
      either ( find  opt-in chr  )
        [append rslt to-string (either(chr == #" ")["+"][chr])  ]
        [append rslt
            join "%" [back back tail(to-string(to-hex(to-integer chr)))]
        ]
   ]
   rslt
]

deplus: func [str] [
	replace/all str "+" " "
	str
]

; --- space-interface follows ...

space-info: func [] [ simplespace-info ]

space-locate-snip: func [ name /local snip-path chained-space ] [
	foreach chained-space space-params [
		snip-path: to-file rejoin [ chained-space url-encode name ".snip" ]
		if exists? snip-path [ return snip-path ]
	]
	none
]

space-exists?: func [name] [
	not none? space-locate-snip name 
]

expand: func [data what /local with-that cache-age cache-quiescence dynasnip-name cached-at] [
	either what/1 = #"!" [
		either what/2 = #"(" [
			parse what [thru "(" copy cache-quiescence to ")"]
			cache-quiescence: to-time load cache-quiescence
			dynasnip-name: next find what ")"
			either (space-exists? rejoin ["cached-" cache-quiescence "-" dynasnip-name]) [
				cached-at: space-meta-get rejoin ["cached-" cache-quiescence "-" dynasnip-name] "cached-at"
				cache-age: (((1 + (now/date - cached-at/date)) * now/time) - cached-at/time)
				either (cache-age < cache-quiescence) [
					with-that: space-get rejoin ["cached-" cache-quiescence "-" dynasnip-name]
					] [
					with-that: space-dyna-exec dynasnip-name
					space-store rejoin ["cached-" cache-quiescence "-" dynasnip-name] with-that
					space-meta-set rejoin ["cached-" cache-quiescence "-" dynasnip-name] "cached-at" now 
					]
				] [
				with-that: space-dyna-exec dynasnip-name
				space-store rejoin ["cached-" cache-quiescence "-" dynasnip-name] with-that
				space-meta-set rejoin ["cached-" cache-quiescence "-" dynasnip-name] "cached-at" now 
				]
			] [
			with-that: space-dyna-exec next what
			]
		] [
		either error? try [pick (find internal-snips what) 2] [
			with-that: space-get what
			] [
			with-that: select internal-snips what
			if (type? with-that) = word! [
				with-that: get with-that
				]
			]
		]
	replace data rejoin ["{" what "}"] with-that
	]

space-expand: func [data] [
	x-rule: [thru "{" copy to-be-xed to "}"]
	to-be-xed: none
	forever [
		parse data x-rule
		either to-be-xed = none
			[return meta-to-esc data]
			[data: expand esc-to-meta data to-be-xed]
		;print to-be-xed
		to-be-xed: none
		]
	]

space-get: func [name /local loc] [
	either none? loc: space-locate-snip name
		[ rejoin ["[describe " name " here]"] ]
		[ read to-file loc ]
]

space-store: func [name data] [
	if = name "" [ return ]
	write to-file rejoin [ (first space-params) (url-encode name) ".snip" ] data
	]

space-delete: func [ name /local fname ] [
	if = name "" [ return false ]

	fname: to-file join (first space-params) (url-encode name)
	if not any [
		(exists? join fname ".snip")
		(exists? join fname ".meta")
	] [ 
		return false
	]

	if exists? join fname ".snip" [ delete join fname ".snip" ]
	if exists? join fname ".meta" [ delete join fname ".meta" ]

	true
]

space-sys-dir: func [/local files snips chained-space] [
	files: copy []
	snips: copy []
	foreach chained-space space-params [ append files read to-file chained-space ]
	foreach file unique/case files [
		if = (skip to-string file (length? to-string file) - 5) ".snip" [
			append snips dehex deplus copy/part to-string file (length? to-string file) - 5
		]
	]
	snips
]

space-dir: func [/local snips] [
	snips: copy []
	foreach s space-sys-dir [
		if not system-snip? s [
			append snips s
		]
	]
	snips
]

system-snip?: func [ snip ] [
    not none? any [
	begins-with? snip "sys-"
	begins-with? snip "sysdata-"
	begins-with? snip "new-"
	begins-with? snip "app-"
	begins-with? snip "appdata-"
	begins-with? snip "cached-"
    ]
]

space-dyna-dir: func [] [
	read to-file app-dir
	]

space-dyna-exec: func [name /local temp e calling-path dynasnip-name dynasnip-params dyna-object] [
	;; dyna params splitting
	temp: parse/all name ":"
	dynasnip-name: temp/1
	dynasnip-params: either found? find name ":" [ at name (length? temp/1) + 2 ] [ none ]

	;; dyna packages
	; v2 following (v1: replace/all dynasnip-name "." "/")
	temp: parse/all dynasnip-name "."
	dynasnip-name: last temp
	reverse temp remove temp reverse temp
	calling-path: copy ""
	foreach e temp [ append calling-path join e "/" ]	; rejoin the parts to build the calling-path
		
	if error? try [ dyna-object: do load to-file rejoin [app-dir calling-path dynasnip-name ".r"] ] [
		return rejoin ["__[error loading dynasnip__ from " app-dir calling-path dynasnip-name ".r" "]"]
		]
	;; refine the dyna-object to pass the relative path to the dyna's package
	;; this allows for greater flexibility in package-naming
	dyna-object: make dyna-object [ package-path: calling-path ]
	either error? error: try [hres: dyna-object/handle dynasnip-params] [
		disarm error return mold error
		] [
		hres
		]
	]

space-meta-get-all: func [snipname] [
	either error? try [
		rslt: load to-file rejoin [(first space-params) url-encode snipname ".metadata"]
	] [
		return none
	] [
		return rslt
	]
]

space-meta-get: func [snipname name] [
	allmd: space-meta-get-all snipname
	if = allmd none [return none]
	foreach [key value] allmd [if (to-string key) = name [return value]]
	return none
	]

space-meta-set: func [snipname name value] [
	metadata-filename: to-file rejoin [(first space-params) url-encode snipname ".metadata"]
	allmd: space-meta-get-all snipname
	if = allmd none [allmd: []]
	forskip allmd 2 [if allmd/1 = name [remove allmd remove allmd]]
	allmd: head allmd
	insert/only allmd value
	insert allmd name
	save metadata-filename allmd
	]

space-meta-reset: func [snipname] [
	metadata-filename: to-file rejoin [(first space-params) url-encode snipname ".metadata"]
	save metadata-filename []
	]
