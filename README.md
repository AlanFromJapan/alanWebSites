# alanWebSites
Source of my websites, for now electrogeek.cc. It's a port from an existing site, so I needed an engine that could server static pages while allowing me to do some dynamic things also.
And since Python2 is my tool of choice these days at work, my choice was made to use Flask.

You will find here the engine written to run on Flask (but should be easily adepted to other WSGI tool.
Features:
* Wiki syntax support (partial)
* Online page edition
* Single user (admin) login
* Templates supported
* Main important config values in a config file
* File system based (no DB)
* Multiple file upload function

Won't be supported ('cause I don't care):
* Blog engine
* Collaborative system with multiple users
* Extensive fancy new stuff

## Install

###Prepare

* sudo apt-get install emacs-nox git python-setuptools
* sudo easy_install pip
* sudo pip install Flask
* sudo pip install futures
* sudo pip install RPi.GPIO

###Install

Make a user to run _webuser_ the website only, no login possible (_passwd -l webuser_), minimum rights.  
Make a folder /use/local/website/electrogeek.PROD/  
Make the owner of the folder _webuser_, he should be the only one with write access.  
In that folder, as user _webuser_, do _git clone https://github.com/AlanFromJapan/alanWebSites.git ._  
Rename and edit the _electrogeek.sample.ini_ as _electrogeek.ini_  
If you don't run on a RPI, comment out all the RPI GPIO reference in the ledz.py  
Edit the start/stop scripts to reflect the DEV or PROD you run.  
Insert as root prerouting rule to redirect port 80 to port 8080 (because you're not root, can't open port less than 1024) : iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080  

###Finish
Remove write access to electrogeek.ini to all, and change owner to root (but leave read all), so even if server is compromised you cant change settings to show other places.  


