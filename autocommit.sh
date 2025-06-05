#!/bin/sh

#Schedule me with cron
#52 13 * * * /path/to/electrogeek.PROD/autocommit.sh >> /tmp/autocommit.log 2>&1

#datetime of the commit
X=`date +"%Y/%m/%d@%H:%M:%S"`

echo Starting autocommit at $X

#change to the batch directory
cd "$(dirname "$0")"

#1 add
git add -A 

#2 commit
CommitMessage="Autocommit from $HOSTNAME - $X"
git commit -m "$CommitMessage"

#3 push
git push origin master


