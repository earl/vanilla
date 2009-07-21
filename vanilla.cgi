#!@@path-to-rebol@@ -cs

REBOL [
    Title:  "vanilla cgi wrapper"
    Date:   2003-09-22
    Rights: {
        Copyright (C) 2000-2007 Andreas Bolka, Christian Langreiter
        Licensed under the Academic Free License version 2.0.
    }
]

;; debugging support
if not none? find __cgi: decode-cgi system/options/cgi/query-string to-set-word "debug"
    [ print "Content-type: text/plain^/" ]

;; vhost support
__vhost-conf: to-file rejoin [ "vanilla.conf-" system/options/cgi/server-name ]
__script-name: last parse system/options/script "/"
either exists? __vhost-conf
    [ do load __vhost-conf ]
    [ do load to-file join __script-name ".conf" ]

;; tell vanilla that the config has already been loaded
__config-loaded: true

;; load vanilla, restore vanilla's script header
__script: load/header to-file join vanilla-root "vanilla.r"
system/script/header: first __script
do next __script


; -------------------
; vim: set syn=rebol:
