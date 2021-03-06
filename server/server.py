# server.py
# (c) 2016 Alexander Bausk

# Sources:
# https://github.com/hfaran/CitySportsLeague-Server/blob/master/src/app.py
# http://stackoverflow.com/questions/14385048/is-there-a-better-way-to-handle-index-html-with-tornado
# https://github.com/zhanglongqi/TornadoAJAXSample
# http://www.tornadoweb.org/en/stable/webframework.html

import logging
import os
import os.path
import socket

import tornado.escape
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket

import metabook.api.sessions
import metabook.api.ajax
import metabook.pages
from metabook.config import metabook_config

# from tornado_json.routes import get_routes


from tornado.options import define, options

define("port", default=metabook_config.port, help="run on the given port", type=int)
define("path", default=os.getcwd(), help="directory to serve Metabook from", type=str)
define("templates", default=metabook_config.templates, help="templates directory", type=str)
define("static", default=metabook_config.static, help="static directory", type=str)


class Application(tornado.web.Application):
    def __init__(self):

        self.solvers = {}
        self.formatters = {}
        handlers = [
            (r"/" + metabook_config.routes.tree, metabook.pages.RedirectHandler),
            (r"/" + metabook_config.routes.tree + r"(/^/+)+", metabook.pages.RedirectHandler),
            (r"/" + metabook_config.routes.tree + r"(/.+)*/", metabook.pages.TreeHandler, dict(init=0)),
            (r"/" + metabook_config.routes.graph + r"/(.*)", metabook.pages.GraphHandler),
            (r"/" + metabook_config.routes.api.file + r"/(.*)", metabook.api.ajax.FileHandler, {'formatters': self.formatters}),
            (r"/" + metabook_config.routes.api.template + r"/(.*)", metabook.api.ajax.TemplateHandler),
            (r"/" + metabook_config.routes.api.solvers + r"/(.*)", metabook.api.ajax.SolverHandler),
            (r"/" + metabook_config.routes.api.sessions + r"/(.+)", metabook.api.sessions.SessionHandler, {'solvers': self.solvers, 'formatters': self.formatters}),
            (r"/.*", metabook.pages.RedirectHandler)

        ]

        settings = dict(
            cookie_secret="__TODO:_GENERATE_YOUR_OWN_RANDOM_VALUE_HERE__",
            template_path=os.path.join(os.path.dirname(__file__), options.templates),
            static_path=os.path.join(os.path.dirname(__file__), options.static),
            xsrf_cookies=False,
        )
        super(Application, self).__init__(handlers, debug=True, **settings)
        # TODO: Remove debug=True in production


def main():
    tornado.options.parse_command_line()
    app = Application()

    app.listen(options.port)
    myip = socket.gethostbyname(socket.gethostname())
    print("Metabook server started at %s" % myip)
    # tornado.ioloop.IOLoop.current().add_timeout()
    tornado.ioloop.IOLoop.current().start()


    logging.info("Exit...")


if __name__ == "__main__":
    main()
