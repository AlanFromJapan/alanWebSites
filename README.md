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

## Install

### Prepare

Mandatory
* sudo apt-get install git python3 python3-pip
* sudo python3 -m pip install flask

Optional if you use the RPI and Led
* sudo pip3 install futures
* sudo pip3 install RPi.GPIO

### Install

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
1. Setup an autorenew of the letsencrypt certificate with *root's* crontab: `11 4 13 */2 * certbot renew`

## Troubleshooting

### Everything looks running but I get a connection error when I access the site
Most likely the port redirection rule is gone, give it a try again : you need to reinput it at each reboot unless made persistent.

### Port routing issues

You can list the rules by:

`iptables -t nat -L`

You can't *disable* rules with iptables, so you have to delete the rule and re-add it (notice the `-D` to delete):

`iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8080`

## Finish  
Remove write access to config,py to all, and change owner to root (but leave read all), so even if server is compromised you cant change settings to show other places.  


