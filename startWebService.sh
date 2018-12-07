#!/bin/bash

ROOTFOLDER=/usr/local/websites/electrogeek.PROD
#change the file owner, just to be sure (for page edition)
sudo chown -R webuser $ROOTFOLDER/static/*

#reset the group owner of the GPIO 
#sudo chown root.gpio /dev/gpiomem 
#sudo chmod g+rw /dev/gpiomem

#start
sudo -u webuser -s nohup /usr/bin/python $ROOTFOLDER/electrogeek_flask.py &

#give 2 secs for service to start
sleep 2
#check that the startup went nicely
PID=`ps -fe | grep 'electrogeek_flask.py' | grep webuser | grep -v root | awk '{print $2}' `
if [ -z "$PID" ]; then
    echo "ERROR! FLASK webserver not started."
else
    echo "FLASK Webserver started !"
fi
