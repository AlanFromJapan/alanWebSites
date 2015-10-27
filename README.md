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

Won't be supported ('cause I don't care):
* Blog engine
* Collaborative system with multiple users
* Extensive fancy new stuff
