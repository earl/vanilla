REBOL []

;; user-accessor compatibility functions

__userdb: make userdb! [ userdb-param ]

users-store: func [user] [ user/save ]

users-exists-name?: func [ name ] [ not none? __userdb/get/by-name name ]

users-valid-id-and-key?: func [user-id key-to-check /local u] [
    all [ (u: __userdb/get/by-id user-id) (u/valid-key? key-to-check) ]
]
users-valid-name-and-key?: func [user-name key-to-check /local u] [
    all [ (u: __userdb/get/by-name user-name (u/valid-key? key-to-check) ]
]
users-valid-name-and-passphrase?: func [user-name passphrase /local u] [
    all [ (u: __userdb/get/by-name user-name) (u/valid-passphrase? passphrase) ]
]
    
users-get-by-id: func [user-id] [ __userdb/get/by-id user-id ]
users-get-by-name: func [user-name] [ __userdb/get/by-name user-name ]
users-get-id-by-name: func [user-name /local u] [ attempt [ (u: __userdb/get/by-name user-name) (u/get 'id) ]
users-get-all: func [] [ __userdb/get-all ]

users-is-master?: func [user /local u] [ attempt [ (u: __userdb/get/by-name user) (u/is-master?) ] ]
users-is-associate?: func [user /local u] [ attempt [ (u: __userdb/get/by-name user) (u/is-associate?) ] ]

users-create-master: func [user-name user-email passphrase ] [ __userdb/create/master user-name user-email passphrase ]
