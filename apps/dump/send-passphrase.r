; 2001-09-09 earl

make object! [
	doc: "sends a given user a new passphrase"

	genpasswd: func [/local password chars a] [
		; set of valid characters for a password
		chars: make bitset! [#"a" - #"z" #"A" - #"Z" #"0" - #"9" ] ; "!,.$#%&?"]

		random/seed now/time
    	password: copy ""
    	while [not (length? password) = 8][
			a: random #"z"
			if find chars a [insert password a]
    		]

		return password
		]

	handle: func [/local u newpwd] [
		if error? try [submitted] [ return "" ]

		if error? try [username] [
			return "__Error:__ No username, no new passphrase. Simple rule, eh?"
			]
		if (not users-exists-name? username) [
			return "__Error:__ Thou shalt be created first! (which means that you'll probably mistyped your username)"
			]
			
		newpwd: genpasswd
		u: users-get-by-name username
		u/set 'passphrase (to-sha1-password vanilla-space-identifier newpwd)
		users-store u
		send to-email (u/get 'email) rejoin [ 
			"Vanilla's Little Passphrase Helper" newline 
			"You've requested a new vanilla password:" newline
			newpwd
			]

		rejoin [
			"__You should receive an email containing the new password!__<br>"
			"Use that to <a href='" vanilla-display-url "vanilla-user-login'>login</a> and "
			"change it at wish." 
			]
		]
	]
