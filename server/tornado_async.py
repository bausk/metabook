from datetime import date
import tornado.escape
import tornado.ioloop
import tornado.web
import tornado.gen, tornado.httpclient

class VersionHandler(tornado.web.RequestHandler):
    def get(self):
        response = { 'version': "0.1",
                     'last_build': date.today().isoformat()}
        self.write(response)
        self.set_header("Content-Type", "text/plain")

class GetGameByIdHandler(tornado.web.RequestHandler):
    def initialize(self, common_string):
        self.common_string = common_string
    def get(self, *id):
        response = { 'id': int(id[0]),
                     'name': 'Crazy Game',
                     'release_date': date.today().isoformat(),
                     'common_string': self.common_string
                     }
        self.write(response)

class GetFullPageAsyncHandler(tornado.web.RequestHandler):
    @tornado.gen.coroutine
    def get(self):
        http_client = tornado.httpclient.AsyncHTTPClient()
        http_response = yield http_client.fetch("http://www.drdobbs.com/web-development")
        response = http_response.body.decode().replace(
            "Most Recent Premium Content", "Most Recent Content")
        self.write(response)
        self.set_header("Content-Type", "text/html")

class ErrorHandler(tornado.web.RequestHandler):
    def get(self, error_code):
        if error_code == 1:
            self.set_status(500)
        elif error_code == 2:
            self.send_error(500)
        else:
            raise tornado.web.HTTPError(500)

application = tornado.web.Application([
    ("/getgamebyid/([0-9]+)/*", GetGameByIdHandler, dict(common_string='Value defined in Application')),
    ("/version", VersionHandler),
    ("/getfullpage/*", GetFullPageAsyncHandler),
    (r"/error/([0-9]+)", ErrorHandler),
    ])

if __name__ == "__main__":
    application.listen(8888)
    tornado.ioloop.IOLoop.instance().start()