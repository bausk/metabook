imports =
    data: require("./data")
    websocket: require("./websocket")

class Session
    constructor: (url) ->
        _.extend @, Backbone.Events
        @id = joint.util.uuid()
        @ws = new imports.websocket("ws://" + url + @id, null, {debug: true, reconnectInterval: 1000, maxReconnectInterval: 30000, reconnectDecay: 1.5})
        @ws.onopen = @onopen
        @ws.onmessage = @onmessage
        @ws.onclose = @onclose

    onopen: (evt) ->
        console.log('<connect.js connection:open>')
        Backbone.trigger "connection:open", @

    connect_file: (path) ->
        @file = new Promise( (resolve, reject) =>
            msg = @new_message(type: 'message:file:connect', content: {path, query:config.file.query})
            @ws.send(msg.serialize())

            @listenTo Backbone, 'message:file:connected', resolve
            @listenTo Backbone, 'message:file:error', reject

        )
        @file

    new_message: ({type, content}) ->
        Message.new(
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
        message = new Message(JSON.parse(evt.data))
        Backbone.trigger message.header.msg_type, message

    onclose: (evt) ->
        console.log "<connect.js session closed>"
        Backbone.trigger 'connection:closed', @


    custom_events:
        'run' : @prototype.run_cell


class Message
    constructor: ({@header, @parent_header, @metadata, @content}) ->

    @new: ({session, msg_type, header, parent_header, metadata, content}) ->
        header ?= @defaults.header()
        header.session = session
        header.msg_type = msg_type
        metadata ?= @defaults.metadata
        parent_header ?= @defaults.parent_header
        content ?= @defaults.content

        new Message({header, parent_header, metadata, content})

    @defaults:
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