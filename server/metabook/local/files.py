import os
from tornado.options import options
from urllib.parse import urlparse
from ..config import metabook_config as config
import json


def open_file_as_json(path: str, query: str): #path is local, relative to notebook root, with URI parameters if any
    lpath = path_to_template() if query == "new" else local_path(urlparse(path).path)

    with open(lpath) as datafile:
        data_json = json.load(datafile)
    return data_json


def request_path(uri: str):
    return uri.rstrip('/') if uri else ''


def clean_uri(uri: str):
    return uri if uri else ''


def local_path(uri: str) -> str:
    return os.path.abspath(options.path + "/" + request_path(uri))


def path_to_template(path=None):
    if path is None:
        return local_path(config.routes.files.default_template)
    else:
        return local_path(path)


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
    # TODO from data json,
    try:
        del data['id']
    except KeyError:
        pass
    return json.dumps(data, indent=4)

