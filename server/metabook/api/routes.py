import tornado.web
import tornado.gen
import os
from tornado.options import options
import json
from pprint import pformat
from urllib import parse


class MainHandler(tornado.web.RequestHandler):

    def initialize(self, init):
        # http://www.tornadoweb.org/en/stable/web.html#entry-points
        self.foo = "Bar " + str(init)
        pass

    @tornado.gen.coroutine
    @tornado.web.addslash
    def get(self, arg1):
        self.render("index.html", path=options.path, arg1=arg1, foo=self.foo)


class GraphHandler(tornado.web.RequestHandler):

    @tornado.gen.coroutine
    def get(self, arg1):
        local_path = os.path.abspath(options.path + "/" + arg1)
        try:
            with open(local_path) as data_file:
                data = json.load(data_file)
            self.render("graph.html", path=options.path+"|"+arg1, data=pformat(data))
        except EnvironmentError:
            raise tornado.web.HTTPError(404)