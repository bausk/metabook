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


@click.command()
@click.option('-p', '--port', default=8888, type=int, required=True,
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
        cookie_secret=(cookie_secret if cookie_secret
                       else uuid.uuid4().hex),
        app_config=app_config,
        login_url="/api/auth/playerlogin"
    )

    # Create server
    http_server = tornado.httpserver.HTTPServer(
        Application(
            routes=get_routes(wlsports.api),
            settings=settings,
            db_conn=wlsports.db,
        )
    )
    # Bind to port
    http_server.listen(port)

    # Register signal handlers for quitting
    signal.signal(signal.SIGTERM, sig_handler)
    signal.signal(signal.SIGINT, sig_handler)

    # Start IO loop
    tornado.ioloop.IOLoop.instance().start()

    logging.info("Exit...")

if __name__ == "__main__":
    main()

inspect.getargs()