import tornado.web
import tornado.gen
import os
from tornado.options import options
from .local.filepaths import request_path, host_info, local_path
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
        remote_root, remote_base, level_up_path = host_info(self.request, request_path(uri))
        dirlist = []
        filelist = []

        for filename in os.listdir(lpath):
            file_path = os.path.join(lpath, filename)
            if os.path.isdir(file_path):
                # is a directory
                bisect.insort(dirlist, filename)

            elif filename.endswith(metabook_config.extension):
                # is a graph file
                bisect.insort(filelist, filename)

        self.render("index.html", lpath=lpath, root=remote_root, rbase=remote_base, dirlist=dirlist,
                    filelist=filelist, uri=request_path(uri), level_up_path=level_up_path)


class GraphHandler(tornado.web.RequestHandler):
    @tornado.gen.coroutine
    def get(self, uri):
        lpath = local_path(uri)
        remote_root, _, level_up_path = host_info(self.request, request_path(uri))

        def graph_json():
            if 'new' in self.request.arguments:
                return ""
            try:
                with open(lpath) as data_file:
                    data = json.load(data_file)
            except EnvironmentError:
                raise tornado.web.HTTPError(404)
            return data

        self.render("graph.html", lpath=lpath, root=remote_root, uri=request_path(uri),
                    level_up_path=level_up_path, data=graph_json(), request=self.request)
