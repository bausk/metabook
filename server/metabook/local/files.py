import os
from tornado.options import options
from urllib import parse
from ..config import metabook_config as config
import json

def request_path(uri: str):
    return uri.rstrip('/') if uri else ''

def clean_uri(uri: str):
    return uri if uri else ''


def local_path(uri: str) -> str:
    return os.path.abspath(options.path + "/" + request_path(uri))


def host_info(request, path) -> tuple:
    protocol = request.protocol
    remote_root = request.host
    level_up_path = path.rpartition('/')[0]
    return protocol, remote_root, level_up_path


def uri_parse(uri: str) -> (str, str):
    if '/' not in uri:
        return uri, ""
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


def convert_default(data):
    if type(data) is str:
        data = json.loads(data)
    try:
        del data['id']
    except KeyError:
        pass
    return json.dumps(data, indent=4)

