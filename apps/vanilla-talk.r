; chl, 2001-03-05

make object! [
	doc: "a simple chat system"
	talk-max: 30
	talk-buffer: space-meta-get "vanilla-talk" "talk-buffer"
	login-msg: rejoin [
		"<i>Hey, would you please <a href=^"" vanilla-display-url "vanilla-user-login&redirect-to=vanilla-talk^">login</a>"
		"to talk with us?</i>"
		]
	double: func [i] [i: to-string i either (= 2 (length? i)) [i] [join "0" i]] 
	talk-format: func [/local lines r] [
		r: make string! 128
		lines: space-meta-get "vanilla-talk" "talk-buffer"
		foreach line lines [
			append r rejoin ["<small> " line/1 ":" line/2 " __*" line/3 "*:__</small> " line/4 "<br><br>"]
			]
		r
		]
	handle: func [/local talk-buffer t] [
		talk-buffer: space-meta-get "vanilla-talk" "talk-buffer"
		if (= none talk-buffer) [talk-buffer: [] space-meta-set "vanilla-talk" "talk-buffer" []]
		either error? try [talk-of-town] [
			either (= user none) [
				rejoin [login-msg "<br><br>" talk-format]
				] [
				talk-format
				]
			] [
			if (= user none) [return rejoin [login-msg "<br><br>" talk-format]]
			if ((length? talk-of-town) < 5) [return join "<i>A little more substance, please!</i><br><br>" talk-format]
			t: now/time
			insert/only talk-buffer reduce [t/hour double t/minute user/get 'name replace/all replace/all talk-of-town "^M^/" "^/" "^/" ""]
			while [(length? talk-buffer) > talk-max] [
				reverse talk-buffer remove talk-buffer reverse talk-buffer
				]
			space-meta-set "vanilla-talk" "talk-buffer" talk-buffer
			talk-format
			]
		]
	]
