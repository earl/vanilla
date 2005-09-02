; ng-userdb.r
; 2000-10-29, 2000-11-20
; 2001-06-12	earl
;	* bug fixed: some vars were not declared to be /local
; 2001-07-16	earl
;	* hashes passwords supporting javascript frontend encryption
;	  and appropriate fallback handling
; 2003-03-20	earl
;	* started refactoring as ng-userdb
;	INCOMPATIBLE CHANGES:
;	    - only user data is persisted, no complete objects anymore
;	    - instead of a space-wide hash salt, a per-user salt is used ('passsalt)
;	    - users-store deprecated, use userdb/save instead
;	    - users-create-master deprecated, use userdb/create/master instead
;	    - users-get-* deprecated, use userdb/get-all and userdb/get instead
;	    - users-exists-name? deprecated, use userdb/get/by-name instead
;	    - users-valid-* deprecated; use userdb/get and user/valid-key? 
;		or user/valid-passphrase? instead
;	    - users-is-master? and users-is-associate? deprecated, use user/is-....? instead
;	    - user/get-all and user/get-all-keys removed [never used, direct access via /data]
; 2005-03-19	earl
;	* moved compatibility functions to userdb-compat.r

user!: make object! [
    _container: none

    ;; data
    data:   []

    ;; data access
    get:    func [ key ] [ select data key ]
    erase:  func [ key ] [ remove/part (find data key) 2 ] ; remove none == none
    set:    func [ k v ] [ erase k repend data [ k v ] self ]
    ; get-all, get-all-keys removed due to non-usage; direct access to data is avail anyway

    ;; convenience funcs
    is-master?: func [ ] [ = 0 get 'id  ]
    is-associate?: func [ ] [ = true get 'space-associate ]

    valid-key?: func [ key ] [ = key get 'valikey ]
    valid-passphrase?: func [ pass ] [
	if not is-hashed-password? pass [ pass: to-sha1-password (get 'passsalt) pass ]
	= pass get 'passphrase
    ]
    
]

userdb!: make object! [

    _version:	    1.0.0
    userdb-path:    none    

    ;; persistence

    load: func [ id /local parent raw] [ 
	parent: self
	raw: system/words/load to-file rejoin [ userdb-path id ".user" ] 
	; could do version checking
	attempt [ 
	    make user! [ 
		_container: parent
		data: second raw
	    ]  
	]
    ]

    save: func [ user ] [ 
	write 
	    to-file rejoin [ userdb-path (get 'id) ".user" ] 
	    mold reduce [ _version user/data ]
	user
    ]

    ;; db size

    get-max: func [ /local fn ] [
	if not exists? fn: to-file join userdb-path "user.max" [ 
	    set-max -1 
	    return -1
	]
	system/words/load fn
    ]

    set-max: func [ num ] [
	system/words/save to-file join userdb-path "user.max" num
	num
    ]

    ;; user creation

    create: func [ name email pass /master /local salt u ] [
	random/see now/precise
	salt: to-string now/precise
	if not is-hashed-password? pass [ pass: to-sha1-password salt pass ]

	u: make user! []
	u/set 'name	    name
	u/set 'email    email
	u/set 'passphrase pass
	u/set 'passsalt salt
	u/set 'valikey rejoin [random 16777216 "-" random 16777216]
	either master [
	    u/set 'id 0 ; get-max + 1 should work as well
	    u/set 'space-associate true
	] [
	    u/set 'id (get-max + 1)
	    u/set 'space-associate false
	]
	set-max + 1
	u/save
    ]

    ;; retrieval

    get: func [ /by-id id /by-name name /local u ] [
	if by-id 
	    [ return load id ]
	if by-name 
	    [ return foreach u get-all [ if = name u/get 'name [ break/return u ] ] ]
	make error! "No selection criteria specified. Use /by-id or /by-name refinement."
    ]

    get-all: func [ /local users ] [
	users: copy []
	repeat i get-max [ append users load i ]
	users
    ]

]

