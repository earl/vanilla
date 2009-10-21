REBOL []
; simpleuserdb.r
; 2000-10-29, 2000-11-20
; 2001-06-12    earl
;       * bug fixed: some vars were not declared to be /local
; 2001-07-16    earl
;       * hashes passwords supporting javascript frontend encryption
;         and appropriate fallback handling
; 2004-01-11    earl
;   * fixed some nasty empty block bugs

user!: make object! [
    data: copy []
    get-all: func [] [data]
    get-all-keys: func [/local r] [r: [] forskip data 2 [append r data/1] r]
    get: func [key /local result] [result: none foreach [k v] data [if (= k key) [result: v]] result]
    erase: func [key] [forskip data 2 [if (= data/1 key) [remove data remove data]] data: head data]
    set: func [key value] [erase key append data key append/only data value]
    ]

users-get-max: func [] [
    if (not exists? to-file join userdb-param "user.max") [users-set-max -1 return -1]
    return to-integer load to-file join userdb-param "user.max"
    ]

users-set-max: func [i] [
    save to-file join userdb-param "user.max" i
    ]

users-store: func [user /local id] [
    id: user/get 'id
    save to-file rejoin [userdb-param id ".user"] user
    ]

users-create-master: func [user-name user-email passphrase /local u] [
    if = false is-hashed-password? passphrase [
        passphrase: to-sha1-password vanilla-space-identifier passphrase
    ]
    u: make user! []
    u/set 'name user-name
    u/set 'email user-email
    u/set 'passphrase passphrase
    u/set 'space-associate true
    random/seed now/time
    u/set 'valikey rejoin [random 16777216 "-" random 16777216]
    u/set 'id 0
    users-set-max 0
    users-store u
    ]

users-create: func [user-name user-email passphrase /local user] [
    if = false is-hashed-password? passphrase [
        passphrase: to-sha1-password vanilla-space-identifier passphrase
    ]

    user: make user! []
    user/set 'name user-name
    user/set 'email user-email
    user/set 'passphrase passphrase
    user/set 'space-associate false
    random/seed now/time
    user/set 'valikey rejoin [random 16777216 "-" random 16777216]
    user/set 'id (users-get-max + 1)
    users-set-max (users-get-max + 1)
    users-store user
    ]

users-get-by-id: func [user-id] [
    return do load to-file rejoin [userdb-param user-id ".user"]
    ]

users-get-by-name: func [user-name /local u] [
    u: none
    foreach user users-get-all [
        if (= user/get 'name user-name) [
            u: user
            ]
        ]
    u
    ]

users-get-id-by-name: func [user-name /local u] [
    u: users-get-by-name user-name
    either (u = none) [
        return none
        ] [
        return to-integer u/get 'id
        ]
    ]

users-get-all: func [/local users] [
    users: copy []
    for id 0 users-get-max 1 [
        append/only users users-get-by-id id
        ]
    users
    ]

users-get-all-names: func [/local user-names u] [
    user-names: copy []
    for id 0 users-get-max 1 [
        u: users-get-by-id id
        append user-names u/get 'name
        ]
    user-names
    ]

users-exists-name?: func [user-name] [
    either (not = none (find users-get-all-names user-name))
        [return true] [return false]
    ]

users-valid-name-and-passphrase?: func [user-name passphrase /local u] [
    if (not users-exists-name? user-name)
        [return false]
    u: users-get-by-name user-name
    if = false is-hashed-password? passphrase [
        passphrase: to-sha1-password vanilla-space-identifier passphrase
    ]
    either (= u/get 'passphrase passphrase)
        [return true] [return false]
    ]

users-valid-name-and-key?: func [user-name key-to-check /local u] [
    if (not users-exists-name? user-name)
        [return false]
    u: users-get-by-name user-name
    either (= (u/get 'valikey) key-to-check)
        [return true] [return false]
    ]

users-valid-id-and-key?: func [user-id key-to-check /local u] [
    if ((to-integer user-id) > users-get-max) [return false]
    if ((to-integer user-id) < 0) [return false]
    u: users-get-by-id user-id
    return (= u/get 'valikey key-to-check)
    ]

users-is-master?: func [user] [
    if (= user none) [return false]
    return = user/get 'id 0
    ]

users-is-associate?: func [user] [
    if (= user none) [return false]
    return = to-string user/get 'space-associate "true"
    ]
