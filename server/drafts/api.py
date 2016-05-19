from tornado_json.requesthandlers import APIHandler
from tornado_json import schema


class HelloWorldHandler(APIHandler):
    @schema.validate(output_schema={"type": "string"})
    def get(self):
        return "Heeyyyyy"