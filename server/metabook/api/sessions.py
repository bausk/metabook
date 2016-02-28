import tornado.web
import tornado.gen
import tornado.websocket
import uuid

clients = dict()
count1 = 0
count2 = 0

class SessionHandler(tornado.websocket.WebSocketHandler):
    def __init__(self, *args, **kwargs):

        self.id = ""
        self.clients = dict()
        self.count = 0

        super().__init__(*args, **kwargs)

    def check_origin(self, origin):
        return True

    def open(self, *args):
        self.id = self.get_argument("Id")
        self.stream.set_nodelay(True)
        globals()["count2"] += 1
        clients[self.id] = {"id": self.id, "object": self}
        self.clients[self.id] = {"id": self.id, "object": self}

    def on_message(self, message):
        """
        when we receive some message we want some message handler..
        for this example i will just print message to console
        """
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