import tornado.web
import tornado.gen
from metabook.handlers import APIHandler


class StartHandler(APIHandler):
    @tornado.gen.coroutine
    def get(self):
        self.render("index.html")

