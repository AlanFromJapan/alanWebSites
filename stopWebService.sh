#!/bin/bash

PID=`ps -fe | grep 'electrogeek_flask.py' | grep webuser | grep electrogeek.PROD | grep -v root | awk '{print $2}' `
if [ -z "$PID" ]; then
    echo Not running
else
    CMD="sudo kill "$PID
    echo $CMD
    eval $CMD
fi
