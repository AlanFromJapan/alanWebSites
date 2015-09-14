from datetime import datetime
from flask import Flask, render_template, redirect, url_for, request
import os
import ConfigParser
import logging
from logging.handlers import RotatingFileHandler

#http://stackoverflow.com/questions/20646822/how-to-serve-static-files-in-flask
app = Flask(__name__, static_url_path='')
Config = ConfigParser.ConfigParser()

ROOTDIR = None 
LOGFILE = None
HTTPPORT = None

#static pages cache (to avoid reading from disk each time)
StaticPagesCache = dict()

#store static pages (.html) in memory for faster response
def getStatic(page, vFilePath):
    if not StaticPagesCache.has_key(page):
        #not in cache? then add it
        t = None
        #read content of the static file
        with open(vFilePath, mode="r") as f:
            t = f.read().decode("utf-8")
        #and store
        StaticPagesCache[page] = t

    return StaticPagesCache[page]
    

#default page -> redirect
@app.route('/')
@app.route('/index.html')
def homepage():
    #app.logger.warning('A warning occurred (%d apples)', 42)
    return redirect('/home.html')


#serving page through template
@app.route('/<page>.html')
def serveTemplate(page):
    vBody = None

    #make sure this path is a *safe* path
    vFilePath = ROOTDIR + page.lower() + ".html"

    #caching or read from disk
    if Config.getboolean("WebConfig", "CACHING"):
        vBody = getStatic(page.lower(), vFilePath)
    else:
    #read content of the static file
        with open(vFilePath, mode="r") as f:
            vBody = f.read().decode("utf-8")

    #renders
    return renderPageInternal (pPageName=page, pBody=vBody)


#Search page
@app.route('/search.aspx')
def searchPage():
    searchstring = request.args.get('txbSearch')
    vBody = "<h1>All pages containing text '%s':</h1>" % (searchstring)

    for filename in os.listdir(ROOTDIR):
	if os.path.isfile(os.path.join(ROOTDIR, filename)) and filename.lower().endswith(".html"):
            with open(os.path.join(ROOTDIR, filename), mode="r") as f:
                t = f.read().decode("utf-8")
                vCount = t.count(searchstring)
                #if searchstring in t:
                if vCount > 0:
                    vBody = vBody + ('&#x2771; <a href="%s">%s</a> (%d occurences)<br/>' % (filename, filename[:-5], vCount))

    #renders
    return renderPageInternal (pPageName="Search results", pBody=vBody)



#THE function that calls the page rendering and returns the result
def renderPageInternal (pPageName, pBody):
    vYear = datetime.now().strftime('%Y')
    #generate the output by injecting static page content and a couple of variables in the template page
    return render_template(Config.get("Design", "Template"), pagename=pPageName, pagecontent=pBody, year=vYear, isprod=Config.getboolean("WebConfig", "ISPROD"))



########################################################################################
## Main entry point
if __name__ == '__main__':
    #load config file
    Config.read("electrogeek.ini")

    #loading once and for all the config values
    ROOTDIR  = Config.get("WebConfig", "ROOTDIR")
    LOGFILE  = Config.get("WebConfig", "LOGFILE")
    HTTPPORT = Config.get("WebConfig", "HTTPPORT")

    #start the logfile
    #logging.basicConfig(filename="/tmp/flasklogging.log",level=logging.DEBUG)
    handler = RotatingFileHandler(LOGFILE, maxBytes=10000, backupCount=1)
    handler.setLevel(logging.INFO)
    app.logger.addHandler(handler)

    #start serving pages
    app.run(host='0.0.0.0', port=HTTPPORT, threaded=True)
