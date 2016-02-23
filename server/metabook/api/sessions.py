import tornado.web
import tornado.gen
import tornado.websocket

clients = dict()

class SessionHandler(tornado.websocket.WebSocketHandler):
#    def __init__(self, *args, **kwargs):

        #self.id = ""
#        super().__init__(*args, **kwargs)

    def check_origin(self, origin):
        return True


    def open(self, *args):
        self.id = self.get_argument("Id")
        self.stream.set_nodelay(True)
        clients[self.id] = {"id": self.id, "object": self}

    def on_message(self, message):
        """
        when we receive some message we want some message handler..
        for this example i will just print message to console
        """
        print("Client %s received a message : %s" % (self.id, message))
        print('sending back message: %s' % message[::-1])
        self.write_message(message[::-1])

    def on_close(self):
        if self.id in clients:
            del clients[self.id]