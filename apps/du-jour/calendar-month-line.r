; 2001-10-22    earl
;       * display-url

make object! [
    doc: "allows everyone and their mother to switch months"
    handle: func [/local month-abbrevs] [
        month-abbrevs: ["jan" "feb" "mar" "apr" "may" "jun" "jul" "aug" "sep" "oct" "nov" "dec"]

        either error? try [calendar-month] [calendar-month: now/month] [calendar-month: to-integer calendar-month]
        either error? try [calendar-year] [calendar-year: now/year] [calendar-year: to-integer calendar-year]
        if (= calendar-month 1) [
            uno: "dec" due: "jan" tre: "feb"
            uno-link: rejoin [ vanilla-display-url "{.name}&calendar-year=" (calendar-year - 1) "&calendar-month=12"]
            tre-link: rejoin [ vanilla-display-url "{.name}&calendar-year=" calendar-year "&calendar-month=2"]
            ]
        if (= calendar-month 12) [
            uno: "nov" due: "dec" tre: "jan"
            uno-link: rejoin [ vanilla-display-url "{.name}&calendar-year=" calendar-year "&calendar-month=11"]
            tre-link: rejoin [ vanilla-display-url "{.name}&calendar-year=" (calendar-year + 1) "&calendar-month=1"]
            ]
        if ((not = calendar-month 1) and (not = calendar-month 12)) [
            uno: pick month-abbrevs (calendar-month - 1)
            due: pick month-abbrevs calendar-month
            tre: pick month-abbrevs (calendar-month + 1)
            uno-link: rejoin [ vanilla-display-url "{.name}&calendar-year=" calendar-year "&calendar-month=" (calendar-month - 1)]
            tre-link: rejoin [ vanilla-display-url "{.name}&calendar-year=" calendar-year "&calendar-month=" (calendar-month + 1)]
            ]
        rejoin [{<a href="} uno-link {">} uno "</a> / " due " " calendar-year { / <a href="} tre-link {">} tre </a>]
        ]
    ]
