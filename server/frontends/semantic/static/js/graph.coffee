imports = require('./ui')

class MetaGraph extends joint.dia.Graph
    initialize: (attrs, data) ->
        @metabook = data
        @constructor.__super__.initialize.apply(this, arguments)
    custom_events:
        "node": imports.ui.Vent.passover
        "newnode": (ev) ->
            console.log("<graph:newnode>")

module.exports = MetaGraph