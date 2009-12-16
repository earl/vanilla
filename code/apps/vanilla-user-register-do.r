; 2000-11-20, 2001-02-12 (vanilleanisation)
; 2001-05-25    earl
;       * passphrase double-check added
; 2001-07-05    chl
;       * added automatic creation of user 'homesnip'
; 2001-10-22    earl
;       * display-url
;       * username length bugfix
;       * homesnip bugfix

make object! [
    doc: "registers a user if user-name doesn't already exist, create start-{user-name}"
    handle: func [/local user-id new-user-protosnip] [
        if (= users-get-max -1) [space-meta-set "vanilla-options" "space-mode" "closed"]

        if error? try [user-name user-email passphrase1 passphrase2 ] [
            return "__Error:__ Missing user name, e-Mail address or passphrase"
            ]
        if (users-exists-name? user-name) [return "__Error:__ This user name is already taken!"]
        if (1 > length? user-name) [return "__Error:__ Hey, choose a longer user name, nah?"]
        if (4 > length? passphrase1) [return "__Error:__ Hey, your passphrase is no good."]
        if (not = passphrase1 passphrase2) [return "<i>Passphrases given do not match!</i>"]

        either (users-get-max < 0) [
            users-create-master user-name user-email passphrase1
            ] [
            users-create user-name user-email passphrase1
            ]

        ; - 'homesnip'
        new-user-protosnip: space-get "vanilla-new-user"
        replace/all new-user-protosnip "[new-user-name]" user-name
        if not space-exists? user-name [ space-store user-name new-user-protosnip ]

        if = false is-hashed-password? passphrase1
            [ passphrase1: to-sha1-password vanilla-space-identifier passphrase1 ]

        if error? try [ redirect-to ] [ redirect-to: "vanilla-user-login-success" ]
        http-redir rejoin [
            vanilla-get-url
            "?selector=user-login&user-name=" (url-encode user-name)
            "&passphrase=" (url-encode passphrase1)
            "&redirect-to=" redirect-to
            ]
        ]
    ]
