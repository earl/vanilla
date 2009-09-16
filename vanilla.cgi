#!@@path-to-rebol@@ -cs

REBOL [
    Title:  "Synerge Vanilla/R - CGI Frontend"
    Date:   2009-09-16
    Rights: {
        Copyright (C) 2000-2009 Andreas Bolka, Christian Langreiter
        Licensed under the Academic Free License version 2.0.
    }
]

;; debugging support
if find decode-cgi any [ system/options/cgi/query-string "" ] to-set-word 'debug
    [ print "Content-type: text/plain^/" ]

;; load params from config file
use [conf-file] [
    either exists? conf-file: join %vanilla.conf- system/options/cgi/server-name
        [ do load conf-file ]
        [ do load to-file join last parse system/options/script "/" %.conf ]
]

;; load and setup our "module manager"
vanilla-root: to-file vanilla-root
do load join vanilla-root %lib/etc/find-file.r
append searchpath join vanilla-root %lib/
append searchpath join vanilla-root %apps/

;; load vanilla, restore vanilla's script header
use [script] [
    script: load/header find-file %vanilla.r
    system/script/header: first script
    do next script
]

; -------------------
; vim: set syn=rebol:
