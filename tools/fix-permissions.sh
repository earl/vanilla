#!/bin/sh

# vanilla root
chmod o+rx vanilla.cgi
chmod o+r  vanilla.cgi.conf
chmod o+rx code/
chmod o+rx data/

# code/
find code/ -type d -exec chmod o+rx \{} \;
find code/ -type f -exec chmod o+r \{} \;

# data/
find data/ -type d -exec chmod g+s,o+rwx \{} \;
find data/ -type f -user $USER -exec chmod o+rw \{} \;
