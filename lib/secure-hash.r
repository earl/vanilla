REBOL [
	Title: "sha1/md5 convenience functions"
	Author: "earl"
	Version: 0.1 
]

clean-hash-string: func [hash] [
	hash: rejoin [ {"} hash {"} ]
	hash: replace/all hash "#" ""
	hash: replace/all hash "^"" ""
	hash: replace/all hash "{" ""
	hash: replace/all hash "}" ""
	return hash
	]

is-hashed-password?: func [password /local hash-type] [
	hash-type: false
	parse password [
		thru "$" copy hash-type to "$"	
		]

	hash-type
	]

to-md5-password: func [salt pass /local md5] [
	md5: checksum/method (join pass salt) 'md5
	return join "$md5$" clean-hash-string md5
	]

to-sha1-password: func [salt pass /local sha1] [
	sha1: checksum/secure join pass salt
	return join "$sha1$" clean-hash-string sha1
	]
