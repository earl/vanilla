; 2004-05-03	johannes lerch, vdp
; 2004-07-17	earl
; 2005-08-31	added permission check
; 2006-03-30	sticky toggle is no longer displayed for users w/ insufficient
;		permissions

make object! [
    odbname: copy "appdata-sticky"

    handle: func [ /local odb ] [
	if permissions-fail? 'edit snip [
	    ;; insufficient permissions for changing stickyness: don't even
	    ;; display the link
	    return ""
	]
	if not attempt [ sticky ] [
	    return render-stickylink
	]

	;; toggle stickyness
	if not space-exists? odbname [ space-store odbname mold [] ]
	odb: load space-get odbname
	either = "true" sticky 
	    [ odb: unique join odb snip ] 
	    [ odb: exclude odb reduce [ snip ] ]
	space-store odbname mold odb
	http-redir join vanilla-display-url snip
    ]

    render-stickylink: func [ /local sticky ] [
	if not space-exists? odbname [ space-store odbname mold [] ]
	odb: load space-get odbname

	sticky: find odb snip
	rejoin [
	    {<a href="} vanilla-display-url (url-encode snip)
		{&sticky=} either sticky [ "false" ] [ "true" ]
		{">} either sticky [ "unstick" ] [ "stick" ] {</a>}
	]
    ]

]
