; 2001-10-22    earl
;       * display-url
;       * added register link (+redirect)
;       * login redirect

make object! [
    doc: "shows login form only if user is logged in"
    handle: func [/local ct] [
        either (= user none) [
            return rejoin [
                {<i>Please <a href="} vanilla-display-url {vanilla-user-login&redirect-to=^{.name^}">}
                {log in</a> (you may want to }
                {<a href="} vanilla-display-url {vanilla-user-register&redirect-to=^{.name^}">}
                {register</a> first) to post comments!</i>}
                ]
            ] [
            ct: space-get "comments-new-form-template"
            replace ct "[for-snip]" next find snip "-"
            ]
        ]
    ]
