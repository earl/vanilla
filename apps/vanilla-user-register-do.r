; 2000-11-20, 2001-02-12 (vanilleanisation)
; 2001-05-25	earl	passphrase double-check added
; 2001-07-05	chl	added automatic creation of user 'homesnip'

make object! [
	doc: "registers a user if user-name doesn't already exist, create start-{user-name}"
	handle: func [/local res user-id new-user-protosnip] [
		if (= users-get-max -1) [space-meta-set "vanilla-options" "space-mode" "closed"]

		if error? try [user-name user-email passphrase1 passphrase2 ] [
			return "__Error:__ Missing user name, e-Mail address or passphrase"
			]
		if (users-exists-name? user-name) [return "__Error:__ This user name is already taken!"]
		if (4 > length? user-name) [return "__Error:__ Hey, choose a longer user name, nah?"]
		if (4 > length? passphrase1) [return "__Error:__ Hey, your passphrase is no good."]
		if (not = passphrase1 passphrase2) [return "<i>Passphrases given do not match!</i>"]

		res: make string! 256
		append res "<b>"
		append res user-name
		append res ", "
		append res user-email
		append res "</b> registered "
		either (users-get-max < 0) [
			users-create-master user-name user-email passphrase1
			append res "(as master user)."
			] [
			users-create user-name user-email passphrase1
			append res "(as standard user)."
			]
		new-user-protosnip: space-get "vanilla-new-user"
		replace/all new-user-protosnip "[new-user-name]" user-name
		space-store user-name new-user-protosnip
		join res {<br><br>You can now <a href="{script-name}?selector=display&snip=vanilla-user-login">login</a>. Enjoy!}
		]
	]
