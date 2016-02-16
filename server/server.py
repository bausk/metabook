# server.py
# (c) 2016 Alexander Bausk

# Sources:
# https://github.com/hfaran/CitySportsLeague-Server/blob/master/src/app.py
# http://stackoverflow.com/questions/14385048/is-there-a-better-way-to-handle-index-html-with-tornado
# https://github.com/zhanglongqi/TornadoAJAXSample
# http://www.tornadoweb.org/en/stable/webframework.html

import logging
import tornado.escape
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
import os
import os.path
import sys
import uuid
import metabook.api.routes
import metabook.api.sessions
from metabook.config import ServerConfig
# from tornado_json.routes import get_routes


from tornado.options import define, options

define("port", default=ServerConfig['port'], help="run on the given port", type=int)
define("path", default=os.getcwd(), help="directory to serve Metabook", type=str)

class Application(tornado.web.Application):

    def __init__(self):
        handlers = [
            (r"/tree(/.*)?", metabook.api.routes.MainHandler, dict(init=0)),
            (r"/graph/(.*)", metabook.api.routes.GraphHandler),
            (r"/api/session/(.*)", metabook.api.sessions.SessionHandler)

        ]
        settings = dict(
            cookie_secret="__TODO:_GENERATE_YOUR_OWN_RANDOM_VALUE_HERE__",
            template_path=os.path.join(os.path.dirname(__file__), "templates"),
            static_path=os.path.join(os.path.dirname(__file__), "static"),
            xsrf_cookies=True,
        )
        super(Application, self).__init__(handlers, **settings)


def main():
    tornado.options.parse_command_line()
    app = Application()
    app.listen(options.port)
    tornado.ioloop.IOLoop.current().start()
    logging.info("Exit...")

if __name__ == "__main__":
    main()


