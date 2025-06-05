FROM python:3.13-alpine

#at build time you can't set env variable, but you should pass it as a build argument
ARG GITHUB_PAT
ARG GITHUB_USER=AlanFromJapan
ARG GITHUB_EMAIL

#Set the environment variable for the GitHub Personal Access Token
ENV ENV_GITHUB_PAT=${GITHUB_PAT}
ENV ENV_GITHUB_USER=${GITHUB_USER}
ENV ENV_GITHUB_EMAIL=${GITHUB_EMAIL}

#if argument is not set, the build will fail
RUN [ "${GITHUB_PAT}" ] || { echo "GITHUB_PAT build arg is not set. Build aborted (RTFM)."; exit 1; }
RUN [ "${GITHUB_EMAIL}" ] || { echo "GITHUB_EMAIL build arg is not set. Build aborted (RTFM)."; exit 1; }

#get git to clone the repository
RUN apk update && apk add git tzdata

# Set the timezone to Japan
ENV TZ=Asia/Tokyo

# Set the locale to UTF-8
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN mkdir -p /app

# Set the working directory
WORKDIR /app

#Create a user to run the application NOT as root (need a home for pip)
RUN adduser --disabled-password --gecos ''  webuser

#allow the user to write to the /app directory
RUN chown -R webuser:webuser /app

#Switch to non-root user
USER webuser

#Clone the repository (the PAT is used to authenticate and stored for later push)
RUN git clone https://$ENV_GITHUB_PAT@github.com/AlanFromJapan/alanWebSites.git /app

#Set the mail and user for git
RUN git config user.email "$ENV_GITHUB_EMAIL"
RUN git config user.name "$ENV_GITHUB_USER"

#register a script to push changes to the repository daily (at 2:22am)
#NOPE. Docker does not support multiple processes, so we can't run cron jobs inside the container. Will be called from the host machine.
#RUN echo "22 2 * * * /app/autocommit.sh" | crontab -

#Branch is called master, comes from a time the young people didn't know about main (or cared how it's called)
#git change the branch
RUN git checkout master
#git pull the latest changes
RUN git pull origin master

#copy the UPDATED config file
#Mount the config file from the host machine to the container with the -v option at run "-v /path/to/config.py:/app/config.py"
#COPY config.py /app/config.py

#install the requirements
RUN pip install -r requirements.txt

#inform of the port to be exposed
EXPOSE 1234


#Run the application (-u is to avoid buffering)
CMD ["python", "-u", "electrogeek_flask.py"]
