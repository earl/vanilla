REBOL []
; 2000-02-15
; 2000-04-03 - added expansion caps

; required imports: space-param, app-dir

; --- simplespace-specific functions & variables

simplespace-info: "simple vanillaspace access module 0.2.2 2000-04-09"
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

expand: func [data what] [
	either what/1 = #"!"
		[with-that: space-dyna-exec next what]
		[either error? try [pick (find internal-snips what) 2]
			[with-that: space-get what]
			[with-that: select internal-snips what
			 if (type? with-that) = word! [with-that: get with-that]
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
		["[snip not found]"]
	]

space-store: func [name data] [
	write rejoin [simplespace-location url-encode name ".snip"] data
	]

space-dir: func [] [
	files: read simplespace-location
	snips: copy []
	foreach file files [
		if = (skip to-string file (length? to-string file) - 5) ".snip" [append snips deplus dehex copy/part to-string file (length? to-string file) - 5]
		]
	snips
	]

space-dyna-dir: func [] [
	read to-file app-dir
	]

space-dyna-exec: func [name] [
	temp: parse name ":"
	dynasnip-name: temp/1
	dynasnip-params: pick temp 2
	if 
		error? try [
			do load to-file rejoin [resource-dir "apps/" dynasnip-name ".r"]
			]
		[return "[error loading dynasnip]"]
	either error? error: try [hres: handle dynasnip-params] [disarm error return mold error] [hres]
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
	