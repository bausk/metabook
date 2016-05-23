import tornado.web
import tornado.gen
import tornado.websocket
import uuid
from ..core import solver
from .messages import Message, ReplyMessage
clients = dict()
count1 = 0
count2 = 0


class SessionStart(tornado.web.RequestHandler):

    @tornado.gen.coroutine
    def post(self, uri):
        """
        Kranks up a new kernel and starts a new session
        Starts
        """
        # TODO EVERYTHING, this is broken code
        # 1) figure out path and filename
        # 2) generate UUID and place it into structured data
        #
        path, filename = uri_parse(uri)
        data_json = json.loads(self.request.body.decode('utf-8'))
        new_id = str(uuid.uuid4())

        try:
            data_file, filename = open_new_file(local_path(path), filename)
            with data_file:
                new_name = filename
                data_json['metadata']['metabook']['id'] = new_id
                data_file.write(convert_default(data_json))
        except EnvironmentError:
            raise tornado.web.HTTPError(500)
        self.write(
            {"success": True,
             "new_name": new_name,
             "new_path": path + filename,
             "new_id": new_id,

             }
        )

class SessionHandler(tornado.websocket.WebSocketHandler):
    def __init__(self, *args, **kwargs):

        self.solver = None
        self.results = {}
        self.id = ""
        self.handlers = {
            'run_cell': self.run_cell,
            'solve_all': self.solve_all
        }

        super().__init__(*args)

    def check_origin(self, origin):
        return True

    def open(self, *args):
        self.id = args[0]
        self.stream.set_nodelay(True)
        if self.id not in self.application.solvers:
            self.application.solvers[self.id] = solver.IPythonSolver()
        self.solver = self.application.solvers[self.id]

    def on_message(self, message):
        # msg_type of message corresponds to method in self.handlers which normally just map to solver methods
        print("Client %s received a message : %s" % (self.id, message))
        msg = Message(message)
        identifier = msg.header.msg_type
        if identifier in self.handlers:
            result = self.handlers[identifier](msg)
            self.write_message(result.stringify())
            return
        raise EnvironmentError

    def on_close(self):
        if self.id in clients:
            del clients[self.id]

    def run_cell(self, message):
        code = message.content.code
        result = self.solver.run_cell(code)
        return ReplyMessage(solver, result)



    def solve_all(self, message):
        links = message.content.links
        cells = message.content.cells
        result = self.solver.solve_all(cells, links)
        return ReplyMessage(self.results, result)
