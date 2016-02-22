import tornado.web
import tornado.gen
import os
from tornado.options import options

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
        request_path = uri.rstrip('/') if uri else ''
        local_path = os.path.abspath(options.path + "/" + request_path)
        remote_root = "{}://{}".format(self.request.protocol, self.request.host)
        remote_base = self.request.path.rstrip("/")
        remote_base = remote_base[:-len(request_path)] if request_path and remote_base.endswith(
            request_path) else remote_base
        level_up_path = request_path[:request_path.rfind("/")] if request_path else ""

        dirlist = []
        filelist = []
        for filename in os.listdir(local_path):
            file_path = os.path.join(local_path, filename)
            if os.path.isdir(file_path):
                # is a directory
                bisect.insort(dirlist, filename)

            elif filename.endswith(metabook_config.extension):
                # is a graph file
                bisect.insort(filelist, filename)

        self.render("index.html", lpath=local_path, root=remote_root, rbase=remote_base, dirlist=dirlist,
                    filelist=filelist, uri=request_path, level_up_path=level_up_path)


class GraphHandler(tornado.web.RequestHandler):
    @tornado.gen.coroutine
    def get(self, uri):
        local_path = os.path.abspath(options.path + "/" + uri)
        request_path = uri.rstrip('/') if uri else ''
        remote_root = "{}://{}".format(self.request.protocol, self.request.host)
        level_up_path = request_path[:request_path.rfind("/")] if request_path.rfind("/") != (-1) else ""
        try:
            with open(local_path) as data_file:
                data = json.load(data_file)

            self.render("graph.html", lpath=local_path, root=remote_root, uri=request_path,
                        level_up_path=level_up_path, data=data)
        except EnvironmentError:
            raise tornado.web.HTTPError(404)
