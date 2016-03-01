import os
from tornado.options import options

def request_path(uri: str):
    return uri.rstrip('/') if uri else ''

def local_path(uri: str) -> str:
    return os.path.abspath(options.path + "/" + request_path(uri))

def host_info(request, path) -> tuple:
    remote_root = "{}://{}".format(request.protocol, request.host)
    remote_base = request.path.rstrip("/")
    remote_base = remote_base[:-len(path)] if path and remote_base.endswith(
        path) else remote_base
    level_up_path = path[:path.rfind("/")] if "/" in path else ""
    return remote_root, remote_base, level_up_path
