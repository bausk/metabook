from dotmap import DotMap
import json


class Message(DotMap):
    def __init__(self, datastring):
        super().__init__(json.loads(datastring))


class ReplyMessage(DotMap):
    def __init__(self, solver_state, result):
        super().__init__(json.loads("{}"))

    def stringify(self):
        return json.dumps(self.__dict__)
