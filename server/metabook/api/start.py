import tornado.web
import tornado.gen

class StartHandler(tornado.web.RequestHandler):
    @tornado.gen.coroutine
    def get(self):
        self.render("index.html")

