from flask import Flask
from flask import has_request_context, request
from flask.logging import logging
from config import conf
from logging.handlers import RotatingFileHandler

class RequestFormatter(logging.Formatter):
    def format(self, record):
        if has_request_context():
            record.url = request.url
            record.remote_addr = request.remote_addr
        else:
            record.url = None
            record.remote_addr = None

        return super().format(record)

def setFormatter(app : Flask):

    formatter = RequestFormatter(
        '[%(asctime)s] %(remote_addr)s requested %(url)s - %(levelname)s in %(module)s: %(message)s'
    )
    app.logger.handlers = []
    handler = RotatingFileHandler(conf["LOGFILE"], maxBytes=100000, backupCount=2, encoding="utf-8")
    handler.setLevel(conf.get("LOGLEVEL", logging.INFO))
    handler.setFormatter(formatter)
    app.logger.addHandler(handler)