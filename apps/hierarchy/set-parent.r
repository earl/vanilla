; chl 2001-07-06
; 2001-07-12 earl - added security checks

make object! [
	doc: "set the parents of the current snip"
	handle: func [/local i r] [
		if error? try [parent for-snip] [ return "__[set-parent:__ missing paramter <i>parent</i> or <i>for-snip</i>]"]
		permissions-ok? 'edit for-snip

		if = parent "none" [space-meta-set for-snip "parent" none return rejoin ["Reset parent for snip *" for-snip "*."]]
		space-meta-set for-snip  "parent" parent

		return rejoin ["Set parent *" parent "* for snip *" for-snip "*."]
		]
	]
