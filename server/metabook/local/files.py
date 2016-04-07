import os
from tornado.options import options
from urllib import parse
from ..config import metabook_config as config


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


def uri_parse(uri: str) -> (str, str):
    parts = uri.rpartition('/')
    path = parts[0] + parts[1]
    file = parts[2]
    return path, file


def open_new_file(path: str, filename: str = None):
    assert type(config.locals.newfile) is str
    if filename in (None, ''):
        filename = config.locals.newfile.format("")
    for i in range(100):
        try:
            fd = os.open(path + '/' + filename, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        except OSError:
            filename = config.locals.newfile.format(" ({})".format(i))
        else:
            return os.fdopen(fd, 'w'), filename
    raise OSError
