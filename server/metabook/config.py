from dotmap import DotMap

ServerConfig = dict(
    port="8585",
    templates="templates",
    static="static"
)

metabook_config = DotMap(ServerConfig)

metabook_config.locals.newfile = "New metabook{}.ipynb"
metabook_config.extension = [".graph", ".ipynb"]
metabook_config.routes.tree = "tree"
metabook_config.routes.graph = "graph"
metabook_config.routes.files.default_template = "template/default.json"
metabook_config.routes.api.sessions = "api/sessions/"
metabook_config.routes.api.file = "api/file"
metabook_config.routes.api.solvers = "api/solvers"
metabook_config.routes.api.template = "api/templates"
