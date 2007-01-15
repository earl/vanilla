; chl 2001-07-16
; updated 2001-11-16 (made more robust)
; updated 2002-04-21 (now outputs graphxml instead of vanilla-vista-xml ;-) 
; updated 2002-05-09 (made simpler and compatible with vv-4)
; 2007-01-15 earl: complete rewrite

context [
    handle: func [param /local snipname nodes edges] [
        snipname: any [ attempt [ xml-for-snip ] param "start" ]

		if not space-exists? snipname [
			return {<GraphXML><graph><node name="no snip"><label>no snip</label></node></graph></GraphXML>}
		] 

        ;; gather edges up to 2 steps away from snipname
        edges: unique collect 'emit [
            foreach link-1 forwardlinks-for snipname [
                emit/only reduce [ snipname link-1 ]
                foreach link-2 forwardlinks-for link-1 [
                    emit/only reduce [ link-1 link-2 ]
                ]
            ]
            foreach link-1 backlinks-for snipname [
                emit/only reduce [ link-1 snipname ]
                foreach link-2 backlinks-for link-1 [
                    emit/only reduce [ link-2 link-1 ]
                ]
            ]
        ]

        ;; extract nodes from the edges
        nodes: unique collect 'emit [
            foreach e edges [
                emit first e
                emit second e
            ]
        ]

        ;; format graphxml
        rejoin-with collect 'emit [
		    emit {<?xml version="1.0" encoding="ISO-8859-1"?>}
            emit {<GraphXML>}
            emit {<graph>}
            foreach n nodes [
                emit rejoin [ 
                    {<node name="} url-encode n {"><label>} html-encode n {</label></node>}
                ]
            ]
            foreach e edges [
                emit rejoin [ 
                    {<edge source="} url-encode first e {" target="} url-encode second e {" />} 
                ]
            ]
            emit {</graph>}
            emit {</GraphXML>}
        ] "^/"
    ]
]
