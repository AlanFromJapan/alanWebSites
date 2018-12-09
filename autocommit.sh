#!/bin/bash

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


