REBOL [title: "sha1/md5 convenience functions"]

enbase16: func [hash] [enbase/base hash 16]

is-hashed-password?: func [password /local hash-type] [
    hash-type: false
    parse password [thru "$" copy hash-type to "$"]
    hash-type
]

to-md5-password: func [salt pass /local md5] [
    join "$md5$" enbase16 checksum/method (join pass salt) 'md5
]

to-sha1-password: func [salt pass /local sha1] [
    join "$sha1$" enbase16 checksum/method (join pass salt) 'sha1
]
