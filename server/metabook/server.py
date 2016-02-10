from datetime import date
import tornado.escape
import tornado.ioloop
import tornado.web
import tornado.gen, tornado.httpclient




application = tornado.web.Application([
    ("/getgamebyid/([0-9]+)/*", GetGameByIdHandler, dict(common_string='Value defined in Application')),
    ("/version", VersionHandler),
    ("/getfullpage/*", GetFullPageAsyncHandler),
    (r"/error/([0-9]+)", ErrorHandler),
    ])

if __name__ == "__main__":
    application.listen(8888)
    tornado.ioloop.IOLoop.instance().start()