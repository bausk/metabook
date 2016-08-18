imports =
    data: require("./data")
    websocket: require("./websocket")

class Session

    constructor: (url) ->
        @id = joint.util.uuid()
        @ws = new imports.websocket("ws://" + url + @id, null, {debug: true, reconnectInterval: 1000, maxReconnectInterval: 30000, reconnectDecay: 1.5})
        @ws.onopen = @onopen
        @ws.onmessage = @onmessage
        @ws.onclose = @onclose

    onopen: (evt) ->
        console.log('<connection onopen>')

    connect_notebook: (local_path) ->
        msg = @new_message(type: 'connect notebook')
        @ws.send(msg.serialize())

    new_message: ({type, content}) ->
        new Message(
            session: @id
            msg_type: type
            content: content
        )

    run_cell: (node_model, event) ->
        # accepts Node view.
        # node_view.model = Node model
        # node_view.model.cell_model = Cell model, of Metabook collection
        cells = importsimports.data.get_cells(node_model.graph.metabook)
        links = importsimports.data.get_links(node_model.graph.metabook)
        ids = [node_model.id]
        msg = new Message(
            session: @id
            msg_type: "update"
            content: {cells, links, ids}
        )
        @ws.send(msg.serialize())

    solve_all: (metabook_model, event) ->
        cells = imports.data.get_cells(metabook_model)
        links = imports.data.get_links(metabook_model)
        ids = imports.data.get_ids(cells)
        msg = new Message(
            session: @id
            msg_type: "solve"
            content: {cells, links, ids}
        )

        @ws.send(msg.serialize())
        console.log "solve_all: " + @id


    onmessage: (evt) ->
        console.log(JSON.parse(evt.data))

    onclose: (evt) ->
        console.log "<session:closed>"
        Backbone.trigger 'session:closed', @


    custom_events:
        'run' : @prototype.run_cell


class Message
    constructor: ({session, msg_type, @header, @parent_header, @metadata, @content}) ->
        @header ?= @defaults.header()
        @header.session = session
        @header.msg_type = msg_type
        @metadata ?= @defaults.metadata
        @parent_header ?= @defaults.parent_header
        @content ?= @defaults.content

    defaults:
        header: ->
            msg_id: joint.util.uuid()
            username: "default"
            session: ""
            date: ""
            msg_type: "default"
            version: '1'
        metadata: {}
        parent_header: {}
        content: {}

    serialize: ->
        JSON.stringify(this)

module.exports = {Session, Message}