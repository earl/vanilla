; chl, 2001-07-16

make object! [
	doc: "guess!"
	handle: func [p /local w h r s] [
		p: parse/all p ";"
		w: p/1 h: p/2
		r: copy ""
		s: space-expand "{.name}"
		append r rejoin [{<script src="} resource-url {vista.js"></script>}]
		append r rejoin [{<a href="javascript:} "vista('{script-name}?selector=display-text&snip=vanilla-vista-java&vanilla-vista-xml-for-snip=" s {',700,500);">vista</a>}]
		r
		]
	]