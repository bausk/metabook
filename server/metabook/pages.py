import tornado.web
import tornado.gen
import os
from tornado.options import options
from .local.files import request_path, host_info, local_path, uri_parse, clean_uri
import json

from metabook.config import metabook_config
import bisect


class TreeHandler(tornado.web.RequestHandler):


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
    def get(self, uri=None):
        if uri is None:
            self.redirect("/" + metabook_config.routes.tree + "/")
        else:
            self.redirect(uri + "/")

class GraphHandler(tornado.web.RequestHandler):

    @tornado.gen.coroutine
    def get(self, uri):
        lpath = local_path(uri)
        protocol, remote_root, level_up_path = host_info(self.request, request_path(uri))
        self.render("graph.html", lpath=lpath, protocol=protocol, query=self.request.query, root=remote_root, uri=clean_uri(uri),
                    level_up_path=level_up_path, request=self.request, file_name=uri_parse(uri)[1])

