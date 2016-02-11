import tornado.ioloop
import helloworld

from tornado import gen

from tornado_json import schema

from tornado_json.routes import get_routes
from tornado_json.application import Application


def main():
    routes = get_routes(helloworld)
    application = Application(routes=routes, settings={})
    application.listen(8889)
    tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
    main()
