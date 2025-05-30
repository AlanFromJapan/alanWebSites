FROM python:3.13-alpine

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

#Swith to non-root user
USER webuser

#Clone the repository
RUN git clone https://github.com/AlanFromJapan/alanWebSites.git /app

#Branch is called master, comes from a time the young people didn't know about main (or cared how it's called)
#git change the branch
RUN git checkout master
#git pull the latest changes
RUN git pull origin master

#copy the UPDATED config file
COPY config.py /app/config.py

#install the requirements
RUN pip install -r requirements.txt

#inform of the port to be exposed
EXPOSE 1234


#Run the application (-u is to avoid buffering)
CMD ["python", "-u", "electrogeek_flask.py"]
