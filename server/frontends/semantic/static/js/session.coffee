class metabook.api.Session

    constructor: (url) ->
        @id = joint.util.uuid()
        @ws = new WebSocket("ws://" + url + @id)
        @ws.onopen = @onopen
        @ws.onmessage = @onmessage
        @ws.onclose = @onclose
        #_.bindAll @, 'run_cell'
        #@listenTo Backbone, 'node:data_session', @run_cell

    onopen: (evt) ->
        alert(evt)

    run_cell: (node_view, event) ->
        # accepts Node view.
        # node_view.model = Node model
        # node_view.model.cell_model = Cell model, of Metabook collection
        msg = new metabook.messages.Message(
            session: @id
            msg_type: "run_cell"
            content:
                code: node_view.model.get('content')
        )
        @ws.send(msg.serialize())

    solve_all: (metabook_model, event) ->
        msg = new metabook.messages.Message(
            session: @id
            msg_type: "solve_all"
            content:
                cells: metabook_model.get('cells')
                links: metabook_model.get('metadata').metabook.links
        )

        @ws.send(msg.serialize())
        alert "k, " + msg



    onmessage: (evt) ->
        alert(evt)

    onclose: (evt) ->
        alert(evt)

    custom_events:
        'run' : @prototype.run_cell


class metabook.messages.Message
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
