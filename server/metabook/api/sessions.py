import tornado.web
import tornado.gen
import tornado.websocket


class SessionHandler(tornado.websocket.WebSocketHandler):
    @tornado.gen.coroutine
    def get(self):
        self.render("index.html")