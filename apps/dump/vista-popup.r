; chl, 2001-07-16
; 2001-10-22	earl
;		* display-url

make object! [
	doc: "guess!"
	handle: func [p /local w h r s] [
		p: parse/all p ";"
		w: p/1 h: p/2
		r: copy ""
		s: space-expand "{.name}"
		append r rejoin [{<script src="} resource-url {vista.js"></script>}]
		append r rejoin [
			{<a href="javascript:vista('} vanilla-display-url 
			{vanilla-vista-java&vanilla-vista-xml-for-snip=} s {',700,500);">vista</a>}
			]
		r
		]
	]
