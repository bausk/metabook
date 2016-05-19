import tornado.web
import tornado.gen
import tornado.websocket
from urllib.parse import urlparse
from ..local.files import local_path, open_new_file, uri_parse, convert_default, path_to_template
from ..config import metabook_config
import json
import uuid
import os
import metabook.api.format as fmt


class FileHandler(tornado.web.RequestHandler):

    def initialize(self, formatters: dict=None):
        self.formatters = formatters

    def save_formatter(self, formatter: fmt.FileFormatter):
        id = formatter.id()
        self.formatters[id] = formatter

    @tornado.gen.coroutine
    def get(self, uri: str):
        lpath = local_path(urlparse(uri).path)
        self.set_header("Content-Type", "application/json")
        newfile = False

        if os.path.isdir(lpath):
            # intent is to make completely new file from default template
            lpath = path_to_template()
            newfile = True
        try:
            with open(lpath) as data_file:
                # TODO read data. convert raw data to {nodes, links, tabs, metadata} dict
                # TODO formatter will know what to do
                data_json = json.load(data_file)
                format = fmt.define_format(data_json)
                formatter = fmt.FileFormatter(format, data=data_json, newfile=newfile)
                self.write(json.dumps(formatter.get_data()))
                self.save_formatter(formatter)
                # self.write(data_file.read())
        except EnvironmentError:
            raise tornado.web.HTTPError(404)

    @tornado.gen.coroutine
    def post(self, uri):
        """
        Accepts a new metabook in self.request.data. id is present. Desired filename could be given in uri
        """
        # 1) figure out path and filename
        # get formatter by id, if no formatter, create one from data
        #
        path, filename = uri_parse(uri)
        data_json = json.loads(self.request.body.decode('utf-8'))
        id = data_json['id']

        try:
            formatter = self.application.formatters[id]
        except KeyError:
            raise tornado.web.HTTPError(500)
        data = formatter.update_from_wire(data_json)

        try:
            data_file, filename = open_new_file(local_path(path), filename)
            with data_file:
                new_name = filename
                # data_json['metadata']['metabook']['id'] = new_id
                data_file.write(convert_default(data))
        except EnvironmentError:
            raise tornado.web.HTTPError(500)
        self.write(
            {"success": True,
             "new_name": new_name,
             "new_path": path + filename,
             # "new_id": new_id,
             }
        )

    @tornado.gen.coroutine
    def put(self, uri):
        data = self.request.body.decode('utf-8')
        try:
            with open(local_path(uri), "w") as data_file:
                data_file.write(convert_default(data))
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
