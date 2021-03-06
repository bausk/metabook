clients = dict()
count1 = 0
count2 = 0

class SessionHandler(tornado.websocket.WebSocketHandler):
    def __init__(self, *args, **kwargs):

        self.solver = None
        self.id = ""
        self.clients = dict()
        self.count = 0

        super().__init__(*args, **kwargs)

    def check_origin(self, origin):
        return True

    def open(self, *args):
        self.id = args[0]
        self.stream.set_nodelay(True)

        globals()["count2"] += 1
        clients[self.id] = {"id": self.id, "object": self}
        self.clients[self.id] = {"id": self.id, "object": self}

    def on_message(self, message):
        self.count += 1
        new_guid = uuid.uuid4()
        print("Client %s received a message : %s" % (self.id, message))
        print('sending back message: %s' % self.id)
        self.write_message("Id {} with clients {} and counters {}, {}, self.counter {}, UUID {}".format(
            self.id,
            self.clients,
            count1,
            count2,
            self.count,
            new_guid
        )
        )


def on_close(self):
    if self.id in clients:
        del clients[self.id]