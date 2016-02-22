ServerConfig = dict(
    port="8585",
    templates="templates",
    static="static"
)


class Struct:
    def __init__(self, **entries):
        self.__dict__.update(entries)


metabook_config = Struct(**ServerConfig)

metabook_config.extension = ".graph"
metabook_config.param = ".graph"
metabook_config.routes = Struct()
metabook_config.routes.tree = "tree"
metabook_config.routes.file = "graph"
metabook_config.routes.session = "api/session"

