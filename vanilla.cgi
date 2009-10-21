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
do load join vanilla-root %code/libs/etc/find-file.r
append searchpath join vanilla-root %code/libs/
append searchpath join vanilla-root %code/apps/

;; load vanilla, restore vanilla's script header
use [script err] [
    script: load/header find-file %vanilla.r
    system/script/header: first script
    if error? set/any 'err try [do next script] [
        print rejoin [
            "Status: 500 Internal Server Error" newline
            "Content-type: text/html" newline
            newline
            <h1 style="color:red;"> "HTTP 500 Internal Server Error" </h1>
            <p> {Hey there! Unfortunately we can not serve your desired page at
            the moment. Something is wrong over on our side. Do not despair,
            but come back a bit later.} </p>
            <p> {Vanilla tripped over an internal error. The following should
            help in debugging:} </p>
            <pre>
        ]
        err
    ]
]

; -------------------
; vim: set syn=rebol:
