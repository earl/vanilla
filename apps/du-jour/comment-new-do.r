; 2001-07-17    earl    redirection changes
; 2001-08-30    chl     create-backlinks-for inst/ of generate-fast-backlinks
; 2002-04-28    earl    package-path bugfix
; 2004-01-31    chl removed vanilla-base-url
make object! [
    doc: "stores a comment"
    handle: func [/local comments] [
        comments: do load find-file %du-jour/comments.r

        ; check - count cmts - store
        if (error? try [comment-content]) [return "__AI detected:__ Factual error in comment!"]
        if (2 > length? comment-content) [return "__AI detected:__ Factual error in comment!"]
        if (= user none) [return "Won't you login, baby?"]
        store-raw rejoin [ "comment-" comment-for-snip "-" (1 + (comments/count-for comment-for-snip))] comment-content

        snip: join "comments-" comment-for-snip
        create-backlinks-for snip
        http-redir rejoin [ vanilla-display-url snip ]
        ;return space-get snip
        ""
        ]
    ]
