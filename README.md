# alanWebSites
Source of my websites, for now electrogeek.cc. It's a port from an existing site, so I needed an engine that could server static pages while allowing me to do some dynamic things also.
And since Python3 is my tool of choice these days at work, my choice was made to use Flask.

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

## Version

March 2023: move to python3. Pretty sure I did that all years ago an never released, apparently I messed up somewhere. So redid it, or did what was missing, anyway runs on Python3.

# Install as Docker container

## Prepare
1. Get the code and pages `git clone https://github.com/AlanFromJapan/alanWebSites.git .`
1. `cp config.sample.py config.py` and edit to your needs
    - <u>BEWARE:</u> you **must** change  `ROOTDIR` to `/app/static`
1. Create a Github PAT (Personal Access Token) for the instance you will run (NOT a build once-deploy many approach, sorry. simpler to solve at build time)
    - The PAT is necessary to PUSH the pages back to github repo. If you aim at readonly, you can put something dummy.
    - If no PAT is provided then the build will fail: you **must** provide build argument `GITHUB_PAT` 
1. Build `docker build --build-arg GITHUB_PAT=<your PAT for that server> -t electrogeek .`
1. Setup your Nginx to deliver port 1234 (or whichever you decided to share)
1. Run `docker run -p 1234:1234 -v /server/path/to/config.py:/app/config.py -d --restart unless-stopped --name electrogeek-container electrogeek > /tmp/electrogeek.log 2>&1`


# Install on a Vm

## Prepare

Mandatory:
* sudo apt-get install git python3 python3-pip
* sudo python3 -m pip install flask

Optional if you use the RPI and Led:
* sudo pip3 install futures
* sudo pip3 install RPi.GPIO

## Install

1. Make a user to run _webuser_ the website only, no login possible (`passwd -l webuser`), minimum rights.  
1. Make a folder `mkdir -p /use/local/website/electrogeek.PROD.3/`
1. Make the owner of the folder _webuser_, he should be the only one with write access.  
1. In that folder, as user _webuser_, do `git clone https://github.com/AlanFromJapan/alanWebSites.git .`
1. **SWITCH TO THE "Python3" branch**: `git checkout python3`
1. Rename and edit the _config.sample.py_ as _config.py_  
1. Get a HTTPS certificate with letsencrypt with `certbot certonly --standalone -v` and make sure _webuser_ has access to the files
1. Edit the start scripts to reflect the DEV or PROD you run: change the path of log file and the path to the KEY and CERT for HTTPS
1. Insert as root prerouting rule to redirect port 443 to port 8080 (because you're not root, can't open port less than 1024) : `iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8080`
    - NB: that rule won't be saved by default, unless you install some extra package on debian (`apt install iptables-persistent`)
    - Save the rule by `sudo iptables-save > /etc/iptables/rules.v4`
1. Make the site start automatically by adding a *root's* **crontab** entry : `@reboot /path/to/startWebService.sh` 

## Post-Installation

1. Setup an autorenew every other month of the _letsencrypt_ certificate with *root's* crontab: `11 4 13 */2 * certbot renew`
1. You can add another flask server that will listen to port 80 and redirect incoming request to port 443. It's here https://github.com/AlanFromJapan/MinimalHttpsRedirect
    - YES YOU SHOULD USE NGINX or APACHE as a proper WSGI. Yes. Do it.
    - If you go with my dirty solution the install is similar to what described above, you'll figure it out.
1. Sometimes flask has a tendency when running without WSGI and with HTTPS to stop answering randomly. Some dirty tricks (the right answer is USE NGINX or another WSGI in front I read on the net):
    - Restart the service daily at night 
    - Cron a curl request to flask every 10 mins. For a reason I can't fathom, it solves the problem...  ¯\\_ (ツ)_/¯

# Troubleshooting

## Everything looks running but I get a connection error when I access the site
Most likely the port redirection rule is gone, give it a try again : you need to reinput it at each reboot unless made persistent.

## Port routing issues

You can list the rules by:

`iptables -t nat -L`

You can't *disable* rules with iptables, so you have to delete the rule and re-add it (notice the `-D` to delete):

`iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8080`

# Finish  
Remove write access to config,py to all, and change owner to root (but leave read all), so even if server is compromised you cant change settings to show other places.  


