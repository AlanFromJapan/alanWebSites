#!/bin/bash

ROOTFOLDER=`dirname $0`
#change the file owner, just to be sure (for page edition)
sudo chown -R webuser $ROOTFOLDER/static/*

#reset the group owner of the GPIO 
#sudo chown root.gpio /dev/gpiomem 
#sudo chmod g+rw /dev/gpiomem

#start
sudo -u webuser -s nohup /usr/bin/python3 $ROOTFOLDER/electrogeek_flask.py > /tmp/electrogeek_PROD.log 2>&1 &

#give 2 secs for service to start
sleep 2
#check that the startup went nicely
PID=`ps -fe | grep 'electrogeek_flask.py' | grep webuser | grep -v root | awk '{print $2}' `
if [ -z "$PID" ]; then
    echo "ERROR! FLASK webserver not started."
else
    echo "FLASK Webserver started !"
fi
