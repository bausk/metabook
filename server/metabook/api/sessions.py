import tornado.websocket
from metabook.core import solver
from dotmap import DotMap
import json

class SessionHandler(tornado.websocket.WebSocketHandler):
    def __init__(self, *args, **kwargs):

        self.solver = None
        self.results = {}
        self.id = ""
        self.handlers = {
            'update': self.update_subset,
            'solve': self.solve_subset,
        }

        super().__init__(*args)

    def check_origin(self, origin):
        return True

    def open(self, *args):
        self.id = args[0]
        self.stream.set_nodelay(True)
        self.formatter = self.application.formatters[self.request.arguments['notebook_id'][0].decode('utf-8')]
        if self.id not in self.application.solvers:
            self.application.solvers[self.id] = solver.IPythonSolver(self.formatter)
        self.solver = self.application.solvers[self.id]


    def on_message(self, message):
        # msg_type of message corresponds to method in self.handlers which normally just map to solver methods
        print("Client %s received a message : %s" % (self.id, message))
        msg = RequestMessage(message)
        identifier = msg.header.msg_type
        if identifier in self.handlers:
            result = self.handlers[identifier](msg)
            self.write_message(result.stringify())
            return
        raise EnvironmentError

    def on_close(self):
        pass

    def update_subset(self, message):
        links = message.content.links
        cells = message.content.cells
        ids = message.content.ids
        result = self.solver.update_cells(cells, links, ids)
        return ReplyMessage(result)

    def solve_subset(self, message):
        links = message.content.links
        cells = message.content.cells
        ids = message.content.ids
        result = self.solver.solve(cells, links, ids)
        return ReplyMessage(result)


class Message(object):
    def stringify(self):
        return json.dumps(self.__dict__)


class RequestMessage(DotMap):
    def __init__(self, result):
        super().__init__(json.loads(result))


class ReplyMessage(Message):

    def __init__(self, result):
        self.__dict__.update(result)
