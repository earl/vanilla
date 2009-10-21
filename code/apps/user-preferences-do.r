; 2001-05-25
; 2001-05-25    earl
;           * passphrase double-check added
;           * email is now really stored
;           * passphrase-change is only handled if an old-passphrase is given
; 2001-07-17    earl    security changes adopted

make object! [
    doc: "handles changes of user preferences"
    handle: func [/local err length-err] [
        either = user none [
            "<i>I'd strongly recommend to log in before trying to change user preferences ...</i>"
            ] [
            length-err: false
            err: error? try [
                length-err: ((length? email) < 4) or
                    ( ((length? old-passphrase) > 0) and ((length? new-passphrase1) < 4) )
                ]

            if err [return ""]
            if length-err [
                return "<i>Passphrases and email-adresses must be at least 4 characters or more!</i>"
                ]

            if (length? old-passphrase) > 0 [
                if (not users-valid-name-and-passphrase? (user/get 'name) old-passphrase) [
                    return "<i>Wrong passphrase!</i>" ]
                if (not = new-passphrase1 new-passphrase2) [
                    return "<i>New passphrases given do not match!</i>" ]

                passphrase: new-passphrase1
                if = false is-hashed-password? passphrase [
                    passphrase: to-sha1-password vanilla-space-identifier passphrase
                    ]
                user/set 'passphrase passphrase
                ]

                user/set 'email email
                users-store user
                return "<i>All stored and done!</i>"
            ]
        ]
    ]
