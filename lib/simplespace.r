REBOL []
; 2000-02-15
; 2000-04-03	added expansion caps
; 2000-11-27	dynasnip implementation is now vanillean-esque
; 2000-11-29	dynasnip caching implemented (finally!)
;		space-full-dir/space-dir splitted/added
; 2001-02-16	case insensitivity (snips are stored w/ lower-case names)
; 2001-07-?? 	earl: added dyna-pacakges, fixed a minor dyna-exec bug

; required imports: space-param, app-dir

; --- simplespace-specific functions & variables

simplespace-info: "simple file-based vanillaspace access module 0.2.3 2000-11-29"
simplespace-location: to-file space-param

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

space-info: func [] [
	simplespace-info
	]

space-exists?: func [name] [
	exists? rejoin [simplespace-location url-encode name ".snip"]
	]

expand: func [data what /local with-that cache-age cache-quiescence dynasnip-name cached-at] [
	either what/1 = #"!" [
		either what/2 = #"(" [
			parse what [thru "(" copy cache-quiescence to ")"]
			cache-quiescence: to-time cache-quiescence
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
			[return data]
			[data: expand data to-be-xed]
		to-be-xed: none
		]
	]

space-get: func [name] [
	either space-exists? name
		[read rejoin [simplespace-location url-encode name ".snip"]]
		[rejoin ["[describe " name " here]"]]
	]

space-store: func [name data] [
	write rejoin [simplespace-location url-encode name ".snip"] data
	]

space-sys-dir: func [/local files snips] [
	files: read simplespace-location
	snips: copy []
	foreach file files [
		if = (skip to-string file (length? to-string file) - 5) ".snip" [append snips deplus dehex copy/part to-string file (length? to-string file) - 5]
		]
	snips
	]

space-dir: func [/local snips] [
	snips: make block! 256
	foreach s space-sys-dir [
		either 	(= copy/part s 4 "sys-") or 
			(= copy/part s 8 "sysdata-") or
			(= copy/part s 4 "app-") or
			(= copy/part s 4 "new-") or
			(= copy/part s 8 "appdata-") or
			(= copy/part s 7 "cached-") [
			; niente!
			] [
			append snips s
			]
		]
	return snips
	]

space-dyna-dir: func [] [
	read to-file app-dir
	]

space-dyna-exec: func [name /local temp e calling-path dynasnip-name dynasnip-params dyna-object] [
	temp: parse/all name ":"
	dynasnip-name: temp/1
	dynasnip-params: pick temp 2
	; v2 following (v1: replace/all dynasnip-name "." "/")
	temp: parse/all dynasnip-name "."				; split(.)
	dynasnip-name: last temp
	reverse temp remove temp reverse temp
	calling-path: copy ""
	foreach e temp [ append calling-path join e "/" ]	; rejoin the parts to build the calling-path
		
	if error? try [ dyna-object: do load to-file rejoin [app-dir calling-path dynasnip-name ".r"] ] [
		return rejoin ["__[error loading dynasnip__ from " app-dir dynasnip-name ".r" "]"]
		]
	;; refine the dyna-object to pass the relative path to the dyna's package
	;; this allows for greater flexibility in package-naming
	dyna-object: make dyna-object [ package-path: calling-path ]
	either error? error: try [hres: dyna-object/handle dynasnip-params] [disarm error return mold error] [hres]
	]

space-meta-get-all: func [snipname] [
	either error? try [rslt: load rejoin [simplespace-location url-encode snipname ".metadata"]]
		[return none]
		[return rslt]
	]

space-meta-get: func [snipname name] [
	allmd: space-meta-get-all snipname
	if = allmd none [return none]
	foreach [key value] allmd [if (to-string key) = name [return value]]
	return none
	]

space-meta-set: func [snipname name value] [
	metadata-filename: rejoin [simplespace-location url-encode snipname ".metadata"]
	allmd: space-meta-get-all snipname
	if = allmd none [allmd: []]
	forskip allmd 2 [if allmd/1 = name [remove allmd remove allmd]]
	allmd: head allmd
	insert/only allmd value
	insert allmd name
	save metadata-filename allmd
	]

space-meta-reset: func [snipname] [
	metadata-filename: rejoin [simplespace-location url-encode snipname ".metadata"]
	save metadata-filename []
	]
