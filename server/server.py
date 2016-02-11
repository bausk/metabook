# server.py
# (c) 2016 Alexander Bausk

# Sources:
# https://github.com/hfaran/CitySportsLeague-Server/blob/master/src/app.py
# http://stackoverflow.com/questions/14385048/is-there-a-better-way-to-handle-index-html-with-tornado
# https://github.com/zhanglongqi/TornadoAJAXSample

import logging
import os
import time
import signal
import json
import uuid
import inspect
import click

import tornado.httpserver
import tornado.ioloop
from tornado_json.application import Application
from tornado.log import enable_pretty_logging
from tornado_json.routes import get_routes

import metabook.api
from metabook.config import ServerConfig

def sig_handler(sig, frame):
    """Handles SIGINT by calling shutdown()"""
    logging.warning('Caught signal: %s', sig)
    tornado.ioloop.IOLoop.instance().add_callback(shutdown)

def shutdown():
    """Waits MAX_WAIT_SECONDS_BEFORE_SHUTDOWN, then shuts down the server"""
    MAX_WAIT_SECONDS_BEFORE_SHUTDOWN = 1

    logging.info('Stopping http server')
    http_server.stop()

    logging.info('Will shutdown in %s seconds ...',
                 MAX_WAIT_SECONDS_BEFORE_SHUTDOWN)
    io_loop = tornado.ioloop.IOLoop.instance()

    deadline = time.time() + MAX_WAIT_SECONDS_BEFORE_SHUTDOWN

    def stop_loop():
        now = time.time()
        if now < deadline and (io_loop._callbacks or io_loop._timeouts):
            io_loop.add_timeout(now + 1, stop_loop)
        else:
            io_loop.stop()
            logging.info('Shutdown')

    stop_loop()

@click.command()
@click.option('-p', '--port', default=8585, type=int, required=True,
              help="Port to start server on")
@click.option('--debug', is_flag=True)
def main(port, debug):

    # Create application configuration
    app_config = dict(
        port=port,
        debug=debug
    )

    settings = dict(
        template_path=os.path.join(
            os.path.dirname(__file__), "templates"),
        static_path=os.path.join(os.path.dirname(__file__), "static"),
        gzip=True,
        app_config=app_config
    )

    # Create server
    http_server = tornado.httpserver.HTTPServer(
        Application(
            routes=get_routes(metabook.api),
            settings=settings
        )
    )
    # Bind to port
    http_server.listen(port)

    # Start IO loop
    tornado.ioloop.IOLoop.instance().start()

    logging.info("Exit...")

if __name__ == "__main__":
    main()
