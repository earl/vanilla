; 2003-07-14    earl - created

make object! [

    template-main: replace/all {
        <div style="background-color: white; padding: 15px;">
            [entries]
            <br />
            <small>
                <a href="{vanilla-display-url}vanilla-attach&attach-snip={.url-name}">
                    Upload / manage attachments</a>!
            </small>
        </div>
    } newline ""

    template-entry: replace/all {
        <img src="{resource-url}att.gif" />
        <a href="[url]">[name]</a>, [size-in-kbyte] kB <br />
    } newline ""

    template-noentries: replace/all {
        <i>No attachments for this snip.</i>
    } newline ""

    ; ---

    handle: func [ params /local att-module ] [
        att-module: do load find-file %attach/lib.r
        att-module/template-main: template-main
        att-module/template-entry: template-entry
        att-module/template-noentries: template-noentries

        att-module/handle-list any [ params snip ]
    ]

]
