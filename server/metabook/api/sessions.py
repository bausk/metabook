import tornado.websocket, tornado.web
import tornado.gen
from metabook.core import solver
import metabook.api.format as fmt
from dotmap import DotMap
import json
import jsonpickle
import uuid
from ..local.files import open_file_as_json
from tornado.concurrent import run_on_executor
from concurrent.futures import ThreadPoolExecutor

class SessionHandler(tornado.websocket.WebSocketHandler):
    # Handler API:
    # return content of message. ReplyMessage is formed in on_message
    #
    #
    executor = ThreadPoolExecutor(max_workers=4)

    def __init__(self, *args, **kwargs):

        self.solver = None
        self.formatters = kwargs['formatters']
        self.results = {}
        self.id = ""
        self.handlers = {
            'update': [self.update_subset],
            'solve': [self.solve_subset],
            'message:file:connect': [self.connect_file, self._start_solver],
        }
        self.msg_types = {
            'update': 'update',
            'solve': 'solve',
            'message:file:connect': 'file',
        }
        super().__init__(*args)

    def check_origin(self, origin):
        return True

    def open(self, *args):
        """

        :param args: tuple of (<path on server>,...)
        :return:
        """

        self.id = args[0]
        self.stream.set_nodelay(True)

    @tornado.gen.coroutine
    def on_message(self, message):
        # msg_type of message corresponds to method in self.handlers which normally just map to solver methods
        print("Client %s received a message : %s" % (self.id, message))
        msg = RequestMessage(message)
        identifier = msg.header.msg_type
        if identifier in self.handlers:
            handlers = self.handlers[identifier]
            for handler in handlers:
                try:
                    result, message_type = yield handler(msg)
                    reply = ReplyMessage(
                        parent_header=msg.header,
                        header={
                            "msg_id": str(uuid.uuid4()),
                            "username": "default",
                            "session": self.id,
                            "date": "",
                            "msg_type": "message:" + self.msg_types[identifier] + ":" + message_type,
                            "version": '1'
                        },
                        metadata={},
                        content=result
                    )
                    self.write_message(reply.stringify())

                except Exception as e:
                    result = ""
                    message_type = "error"
                    reply = ReplyMessage(
                        parent_header=msg.header,
                        header={
                            "msg_id": str(uuid.uuid4()),
                            "username": "default",
                            "session": self.id,
                            "date": "",
                            "msg_type": "message:" + self.msg_types[identifier] + ":" + message_type,
                            "version": '1'
                        },
                        metadata={},
                        content=result
                    )
                    self.write_message(reply.stringify())
            return
        raise EnvironmentError

    def save_formatter(self, formatter: fmt.FileFormatter):
        identity = formatter.id()
        self.formatters[identity] = formatter

    def on_close(self):
        if self.id in self.application.solvers:
            del self.application.solvers[self.id]

    @run_on_executor
    def connect_file(self, message):

        path = message.content.path
        query = message.content.query

        newfile = True if query == "new" else False
        try:
            data_json = open_file_as_json(path, query)
        except EnvironmentError:
            raise tornado.web.HTTPError(404)

        my_format = fmt.define_format(data_json)
        formatter = fmt.FileFormatter(my_format, data=data_json, newfile=newfile)
        # TODO: figure out this line
        self.save_formatter(formatter)
        return formatter.get_data(), "connected"

    @run_on_executor
    def _start_solver(self, message):
        if self.id not in self.application.solvers:
            self.application.solvers[self.id] = solver.IPythonSolver()
        self.solver = self.application.solvers[self.id]
        return "", "kernelstarted"

    def update_subset(self, message):
        links = message.content.links
        cells = message.content.cells
        ids = message.content.ids
        result = self.solver.update_cells(cells, links, ids)
        return result,

    def solve_subset(self, message):
        links = message.content.links
        cells = message.content.cells
        ids = message.content.ids
        result = self.solver.solve(cells, links, ids)
        return result,


class Message(object):
    def stringify(self):
        return json.dumps(self.__dict__, cls=Encoder)


class RequestMessage(DotMap):
    def __init__(self, result):
        super().__init__(json.loads(result))


class ReplyMessage(Message):
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)

    @classmethod
    def from_content(self, content):
        pass


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
