#!/bin/bash

#cd /usr/local/websites/electrogeek.DEV
#git ls-files --modified | grep -v .sh | grep -v electrogeek.ini | xargs -i cp ./{} /usr/local/websites/electrogeek.PROD/

#copy only updated (newer) and new files
cp -u -v /usr/local/websites/electrogeek.PROD/static/*.html /usr/local/websites/electrogeek.DEV/static/
cp -u -v /usr/local/websites/electrogeek.PROD/static/files/* /usr/local/websites/electrogeek.DEV/static/files/
cp -u -v /usr/local/websites/electrogeek.PROD/static/static/* /usr/local/websites/electrogeek.DEV/static/static/

