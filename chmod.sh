#!/bin/sh

# vanilla root
chmod 705 apps/
chmod 701 db/
chmod 701 lib/
chmod 707 space/
chmod 705 vanilla.cgi

# apps/
find apps/ -type d -exec chmod 705 \{} \;
find apps/ -type f -exec chmod 604 \{} \;

# db/
chmod 707 db/session/
chmod 707 db/user/
find db/ -type f -user $USER -exec chmod 606 \{} \;

# lib/
find lib/ -type d -exec chmod 701 \{} \;
find lib/ -type f -exec chmod 604 \{} \;

# space/
chmod 705 space/initial/
find space/ -type f -user $USER -exec chmod 606 \{} \;
find space/initial/ -type f -user $USER -exec chmod 604 \{} \;
