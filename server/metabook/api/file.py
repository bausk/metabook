import tornado.web
import tornado.gen
import tornado.websocket
from ..local.files import local_path, open_new_file, uri_parse
from ..config import metabook_config
import json
import uuid

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

    @tornado.gen.coroutine
    def post(self, uri):
        """
        Accepts a new metabook in self.request.data. No id is present. Desired filename could be given in uri
        """
        # 1) figure out path and filename
        # 2) generate UUID and place it into structured data
        #
        path, filename = uri_parse(uri)
        data_json = json.loads(self.request.body.decode('utf-8'))
        new_id = str(uuid.uuid4())

        try:
            data_file, filename = open_new_file(local_path(path), filename)
            with data_file:
                new_name = filename
                data_json['metadata']['metabook']['id'] = new_id
                json.dump(data_json, data_file)
        except EnvironmentError:
            raise tornado.web.HTTPError(500)
        self.write(
            {"success": True,
             "new_name": new_name,
             "new_id": new_id
             }
        )

    @tornado.gen.coroutine
    def put(self, uri):
        data = self.request.body.decode('utf-8')
        try:
            with open(local_path(uri), "w") as data_file:
                data_file.write(data)
        except EnvironmentError:
            raise tornado.web.HTTPError(500)
        self.write(
            {"success": True,
             }
        )


class TemplateHandler(tornado.web.RequestHandler):

    @tornado.gen.coroutine
    def get(self, uri: str):

        lpath = local_path(metabook_config.routes.files.default_template)
        self.set_header("Content-Type", "application/json")

        try:
            with open(lpath) as data_file:
                self.write(data_file.read())
        except EnvironmentError:
            raise tornado.web.HTTPError(404)


class SolverHandler(tornado.web.RequestHandler):

    @tornado.gen.coroutine
    def get(self, uri: str):

        lpath = local_path(uri + metabook_config.routes.files.default_template)
        self.set_header("Content-Type", "application/json")

        try:
            with open(lpath) as data_file:
                self.write(data_file.read())
        except EnvironmentError:
            raise tornado.web.HTTPError(404)
