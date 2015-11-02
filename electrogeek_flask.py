from datetime import datetime
from flask import Flask, render_template, redirect, url_for, request, make_response
import os
import ConfigParser
import logging
from logging.handlers import RotatingFileHandler
import re

#http://stackoverflow.com/questions/20646822/how-to-serve-static-files-in-flask
app = Flask(__name__, static_url_path='')
Config = ConfigParser.ConfigParser()

ROOTDIR = None 
LOGFILE = None
HTTPPORT = None
ISPROD = False

#static pages cache (to avoid reading from disk each time)
StaticPagesCache = dict()

##########################################################################################
#Interpretes the Wiki tags and translate to HTML
def wikilize(html):
    #links
    link = r"((?<!\<code\>)\[\[([^<].+?) \s*([|] \s* (.+?) \s*)?]])"
    compLink = re.compile(link, re.X | re.U)
    for i in compLink.findall(html):
        title = [i[-1] if i[-1] else i[1]][0]
        url = i[1].lower()
        if not url.startswith("http://") and not url.startswith("https://"): 
            url = "/" + url + ".html"
        formattedLink = u"<a href='{0}'>{1}</a>".format(url, title)
        html = re.sub(compLink, formattedLink, html, count=1)

    #bold and italic
    link = r"(//\*\*(.[^*]+)\*\*//)"
    compLink = re.compile(link, re.X | re.U)
    for i in compLink.findall(html):
        url = i[1]
        formattedLink = u"<i><b>{0}</b></i>".format(url)
        html = re.sub(compLink, formattedLink, html, count=1)

    #italic and bold
    link = r"(\*\*//(.[^/]+)//\*\*)"
    compLink = re.compile(link, re.X | re.U)
    for i in compLink.findall(html):
        url = i[1]
        formattedLink = u"<i><b>{0}</b></i>".format(url)
        html = re.sub(compLink, formattedLink, html, count=1)

    #bold
    link = r"(\*\*(.[^*]+)\*\*)"
    compLink = re.compile(link, re.X | re.U)
    for i in compLink.findall(html):
        url = i[1]
        formattedLink = u"<b>{0}</b>".format(url)
        html = re.sub(compLink, formattedLink, html, count=1)

    #italic
    link = r"(//(.[^/]+)//)"
    compLink = re.compile(link, re.X | re.U)
    for i in compLink.findall(html):
        url = i[1]
        formattedLink = u"<i>{0}</i>".format(url)
        html = re.sub(compLink, formattedLink, html, count=1)

    #list item (unordered)
    link = r"^\*\s+(.+)$"
    compLink = re.compile(link, re.X | re.U | re.M) #need the M = multiline to detect begin/end of string
    for i in compLink.findall(html):
        url = i
        formattedLink = u"<li>{0}</li>".format(url)
        html = re.sub(compLink, formattedLink, html, count=1)

    return html

##########################################################################################
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
    

##########################################################################################
#default page -> redirect
@app.route('/')
@app.route('/index.html')
def homepage():
    #app.logger.warning('A warning occurred (%d apples)', 42)
    return redirect('/home.html')


##########################################################################################
#Login page
@app.route('/login', methods=['POST', 'GET'])
def doLogin():
    if request.method == "GET":
        return render_template("login01.html", pagename="login", isprod=ISPROD, message="")
    else:
        vLogin = request.form["login"]
        vPwd = request.form["pwd"]
        
        if vLogin == Config.get("AdminAccount", "Login") and vPwd == Config.get("AdminAccount", "Password"):
            #Login is correct
            resp = make_response( redirect("home.html") )
            
            resp.set_cookie ('username', vLogin)
                
            return resp
        else:
            #incorrect login
            return render_template("login01.html", pagename="login", isprod=ISPROD, message="Login incorrect")



##########################################################################################
#New page creation
@app.route('/new/<page>')
def newPage(page):
    #not logged in? go away
    if None == request.cookies.get('username'):
        return redirect("/home.html")

    targetFilePath = ROOTDIR + page.lower() + ".html"
    #if page already exists just go there
    if os.path.isfile(targetFilePath):
        return redirect("/"+ page.lower() +".html")

    #make an empty page
    with open(targetFilePath, 'a'):
        os.utime(targetFilePath, None)
    #...and go there
    return redirect("/edit/"+ page.lower())

	
##########################################################################################
#Edit page online
@app.route('/edit/<page>', methods=['POST', 'GET'])
def editPage(page):
    #not logged in? go away
    if None == request.cookies.get('username'):
        return redirect("/" + page.lower() + ".html")

    vBody = None
    vFormContent = ""
    vYear = datetime.now().strftime('%Y')
    #make sure this path is a *safe* path
    vFilePath = ROOTDIR + page.lower() + ".html"

    
    #get textbox content from the form post param or from disk
    if request.method == "POST" and "text" in request.form:
            vFormContent = request.form["text"]    
            vBody = vFormContent
    else:
        #caching or read from disk
        if Config.getboolean("WebConfig", "CACHING"):
            vBody = getStatic(page.lower(), vFilePath)
        else:
            #read content of the static file
            with open(vFilePath, mode="r") as f:
                vBody = f.read().decode("utf-8")
        vFormContent = vBody

    #Save or preview or else?
    if request.method == "POST" and "SaveOrPreview" in request.form:
        if request.form["SaveOrPreview"] == "Save":
            #do save
            if None != request.cookies.get('username') and "" != vFormContent.strip():
                #save IF content is not empty and you are logged in
                with open(vFilePath, mode="w") as f:   
                    f.write(vFormContent.strip().encode("utf-8"))
                #and redirect
                return redirect("/" + page.lower() + ".html")
        else:
            if request.form["SaveOrPreview"] == "Preview":
                #do Preview
                pass #do nothing, stay on the page, this will just refresh the preview
        #else:
            #do nothing :P

    #Debug
    #if request.method == "POST":
    #    vFormContent = ",".join(request.form.keys()) + vFormContent    

    #generate the output by injecting static page content and a couple of variables in the template page
    resp = make_response( render_template(Config.get("Design", "EditTemplate"), pagename=page, pagecontent=vBody, year=vYear, isprod=ISPROD, testout=wikilize(vFormContent)))
    
    #Debug
    #if "SaveOrPreview" in request.form and request.form["SaveOrPreview"] == "Preview":
    #    resp.set_cookie ('username', 'xyz')
        
    return resp

    
##########################################################################################
#serving page through template
@app.route('/<page>.html')
@app.route('/<page>')
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

##########################################################################################
#Search page
@app.route('/search.aspx')
def searchPage():
    searchstring = request.args.get('txbSearch')
    vBody = "<h1>All pages containing text '%s':</h1>" % (searchstring)

    for filename in os.listdir(ROOTDIR):
	if os.path.isfile(os.path.join(ROOTDIR, filename)) and filename.lower().endswith(".html"):
            with open(os.path.join(ROOTDIR, filename), mode="r") as f:
                t = f.read().decode("utf-8")
                #count in the file and the filename
                vCount = t.count(searchstring) + filename.count(searchstring)
                #if searchstring in t:
                if vCount > 0:
                    vBody = vBody + ('&#x2771; <a href="%s">%s</a> (%d occurences)<br/>' % (filename, filename[:-5], vCount))

    #renders
    return renderPageInternal (pPageName="Search results", pBody=vBody)



#THE function that calls the page rendering and returns the result
def renderPageInternal (pPageName, pBody):
    vYear = datetime.now().strftime('%Y')
    #generate the output by injecting static page content and a couple of variables in the template page
    return render_template(Config.get("Design", "Template"), pagename=pPageName, pagecontent=wikilize(pBody), year=vYear, isprod=ISPROD)



########################################################################################
## Main entry point
if __name__ == '__main__':
    #load config file
    Config.read("electrogeek.ini")

    #loading once and for all the config values
    ROOTDIR  = Config.get("WebConfig", "ROOTDIR")
    LOGFILE  = Config.get("WebConfig", "LOGFILE")
    HTTPPORT = int(Config.get("WebConfig", "HTTPPORT"))
    ISPROD = Config.getboolean("WebConfig", "ISPROD")
    
    #start the logfile
    #logging.basicConfig(filename="/tmp/flasklogging.log",level=logging.DEBUG)
    handler = RotatingFileHandler(LOGFILE, maxBytes=10000, backupCount=1)
    handler.setLevel(logging.INFO)
    app.logger.addHandler(handler)

    if not ISPROD:
        app.debug = True

    #start serving pages
    app.run(host='0.0.0.0', port=HTTPPORT, threaded=True)
