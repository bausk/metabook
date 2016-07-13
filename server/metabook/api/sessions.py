import tornado.websocket
from metabook.core import solver
from dotmap import DotMap
import json
import jsonpickle


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
            data = result.stringify()
            self.write_message(data)
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
        return json.dumps(self.__dict__, cls=Encoder)


class RequestMessage(DotMap):
    def __init__(self, result):
        super().__init__(json.loads(result))


# Stolen from
# http://stackoverflow.com/questions/2343535/easiest-way-to-serialize-a-simple-class-object-with-simplejson
class Encoder(json.JSONEncoder):
    def default(self, o):

        def _execution_result(v):
            data = {'error_before_exec': v.error_before_exec,
                    'error_in_exec': v.error_in_exec,
                    'execution_count': v.execution_count,
                    'result': v.result,
                    'success': v.success
                    }
            return jsonpickle.dumps(data)

        types = {
            'ObjectId': lambda v: str(v),
            'ExecutionResult': _execution_result
        }
        obj_type = type(o).__name__
        if obj_type in types:
            return types[obj_type](o)
        else:
            return jsonpickle.dumps(o)


class ReplyMessage(Message):
    def __init__(self, result):
        self.__dict__.update(result)
        # data = {}
        # for cell_id, cell_result in result.items():
        #    for port_id, port_result in cell_result.items():
        #        data[cell_id][port_id] = write_results(port_result)
