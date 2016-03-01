import tornado.web
import tornado.gen
import tornado.websocket
from ..local.filepaths import local_path


class FileHandler(tornado.web.RequestHandler):

    @tornado.gen.coroutine
    def get(self, uri: str):

        lpath = local_path(uri)
        self.set_header("Content-Type", "application/json")

        try:
            with open(lpath) as data_file:
                self.write(data_file.read())
        except EnvironmentError:
            raise tornado.web.HTTPError(404)
