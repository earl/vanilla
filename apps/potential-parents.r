; 2001-07-06 	chl
; 2001-07-13	earl
;			* changed layout from radio-button-group to listbox
;			* removed 'parent-select-if.r' dependency

make object! [
	doc: "shows the potential parents (aka backlinks ;-) of the current snip"

	is-parent-of?: func [potential-parent potential-child] [
		if = 
			to-string potential-parent 
			to-string (space-meta-get potential-child "parent") [ 
			return true 
			]
		false
		]

	handle: func [/local r potential-parent potential-parents] [
		r: copy ""
		cur: first next find internal-snips ".name"

		append r {<form method="get" action="{script-name}">}
		append r {<input type="hidden" name="selector" value="display">}
		append r {<input type="hidden" name="snip" value="vanilla-set-parent">}
		append r rejoin [{<input type="hidden" name="for-snip" value="} 
			cur {">}]

		; --- selection
		potential-parents: space-meta-get cur "fast-backlinks"
		if none? potential-parents [return "<i>(no backlinks yet, store first!)</i>"]
		if (= 0 length? potential-parents) [return "<i>(no backlinks!)</i>"]

		append r "<select name=^"parent^" size=^"10^">"
		insert potential-parents "none"
		foreach potential-parent potential-parents [
			status: either is-parent-of? potential-parent cur [ "selected" ] [ "" ]
			append r rejoin [ 
				"<option " status ">" potential-parent "</option><br />"
				]
			]
		append r "</select><br /><br />"

		append r {<input type="submit" value="Set!">}
		append r "</form>"
		]
	]
