make object! [
 doc: "show a list of all snips written by a given user"
 handle: func [ uname /local result result-list my-uid ] [
        result: []
        result-list: []
        my-uid: users-get-id-by-name uname
        if( = my-uid none ) [
                return rejoin ["<b>written dyna-snip:</b> user " uname " not found!"]
                ]
        append result "__this user's snips:__ "
        foreach entry space-dir [
                if( = (space-meta-get entry "last-editor-id") my-uid ) [
                        append result-list rejoin [ "*" entry "*, " ]
                        ]
                ]
        either ( = 0 length? result-list )
                [ append result "<i>none</i> " ]
                [ append result sort result-list
                        replace last result "," " "
                        ]
        return html-format result
        ]
 ]