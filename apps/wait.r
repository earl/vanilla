make object! [

    doc: "wait for param (default: 5) seconds"

    handle: func [ param /local n ] [
        if none? attempt [ n: to-integer param ] [
            n: 5
        ]
        wait n
        ""
    ]

]
