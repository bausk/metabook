import tornado.web
import tornado.gen
import os
from tornado.options import options
from .local.files import request_path, host_info, local_path, uri_parse, clean_uri
import json

from metabook.config import metabook_config
import bisect


class MainHandler(tornado.web.RequestHandler):
    def initialize(self, init):
        # http://www.tornadoweb.org/en/stable/web.html#entry-points
        self.foo = "Bar " + str(init)
        pass

    @tornado.gen.coroutine
    def get(self, uri: str):

        # Scan and generate all files in local path.
        # Output them in a clickable table.
        lpath = local_path(uri)
        protocol, remote_root, level_up_path = host_info(self.request, request_path(uri))
        dirlist = []
        filelist = []

        for filename in os.listdir(lpath):
            file_path = os.path.join(lpath, filename)
            if os.path.isdir(file_path):
                # is a directory
                bisect.insort(dirlist, filename)

            elif any(filename.endswith(x) for x in metabook_config.extension):
                # is a graph file
                bisect.insort(filelist, filename)

        self.render("index.html", protocol=protocol, lpath=lpath, root=remote_root, dirlist=dirlist,
                    filelist=filelist, uri=clean_uri(uri), level_up_path=level_up_path, file_name='')

class RedirectHandler(tornado.web.RequestHandler):
    @tornado.gen.coroutine
    def get(self):
        self.redirect(r"/" + metabook_config.routes.tree + "/")

class GraphHandler(tornado.web.RequestHandler):
    @tornado.gen.coroutine
    def get(self, uri):
        lpath = local_path(uri)
        protocol, remote_root, level_up_path = host_info(self.request, request_path(uri))

        def graph_json():
            if 'new' in self.request.arguments:
                return ""
            try:
                with open(lpath) as data_file:
                    data = json.load(data_file, encoding=data_file.encoding)
            except EnvironmentError:
                raise tornado.web.HTTPError(404)
            return data

        self.render("graph.html", lpath=lpath, protocol=protocol, root=remote_root, uri=clean_uri(uri),
                    level_up_path=level_up_path, data=graph_json(), request=self.request, file_name=uri_parse(uri)[1])
