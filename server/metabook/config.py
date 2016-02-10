from collections import namedtuple


ServerConfig = namedtuple(
    'ServerConfig',
    ['port', 'db_file', 'session_timeout_days', 'cookie_secret', 'debug']
)
