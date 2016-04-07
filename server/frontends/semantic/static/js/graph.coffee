Settings =
    active_menu_class: "context-menu--active"
    context_menu:
        ".element": "#context-menu"
        "svg": "#context-menu2"
    ui:
        actions:
            "Add": metabook.ui.add
            "Edit": metabook.ui.edit
            "Delete": metabook.ui.delete
    id:
        messages: "#messages"
        coords: "#coords"
        graph_container: "#paper_holder"
        paper: "#myholder"
        svg: "#v-2"

Obj =
    graph: undefined
    mainpaper: undefined


$(document).ready ->
    WebSocketTest = undefined

    messageContainer = $(Settings.id.messages)

    WebSocketTest = (ev) ->
        messageContainer.text("WebSocket is supported by your Browser!")
        ws = new WebSocket("ws://" + window.location.host + "/api/session/guise?Id=123456789")

        ws.onopen = ->
            $('#bSend').on("click", ->
                ws.send("New message")
            )
            $('#bClose').on("click", (ev) ->
                ws.close()
                $(messageContainer).text("Connection is forcefully closed")
                $(ev.target).addClass("disabled");
                $('#bSend').addClass("disabled");
                $('#bConnect').removeClass("disabled");
                )
            $('#bClose').removeClass("disabled")
            $('#bSend').removeClass("disabled")
            $(ev.target).addClass("disabled");
        ws.onmessage = (evt) ->
            received_msg = evt.data
            $(messageContainer).text("Message is received..." + received_msg)
        ws.onclose = ->
            $(messageContainer).text("Connection is closed...")


    $('#bConnect').on("click", WebSocketTest)

    makeCounter = ->
        count = 0
        {increment: -> count++
        getCount:  -> count}

    counter = makeCounter()

    $('#bTest1').on("click", ->
        counter.increment()
        alert(counter.getCount())
    )

    # dim the screen while fetching file data
    $("#id2").dimmer({closable:false}).dimmer('show')

    metabook.api.get_template(init_graph, error_graph)


init_graph = (graph_template) ->

    if metabook.api.file_id != ""
        metabook.api.get_file(_.partial(parse_graph, graph_template), error_graph)
    else
        # File is new because there is no id
        # TODO: if file is new, generate ID I guess...
        parse_graph(graph_template, {})

parse_graph = (graph_template, graph_json) ->
    # TODO: build MetabookModel with submodels and bind them to jointjs models

    if Object.keys(graph_json).length == 0
        graph_json = graph_template
    else if not 'metabook' of graph_json.metadata
        graph_json.metadata.metabook = graph_template.metadata.metabook
        graph_json.metadata.metabook.id = joint.util.uuid()


    # TODO: if no metabook metadata, populate from template and generate id


    cells_collection = init_jointjs(graph_template, graph_json)

    notebook = new metabook.models.MetabookModel({'cells': cells_collection}, {template: graph_template, json: graph_json})



    $("#id2").dimmer('hide')

    $("#uiLeftSidebar").sidebar({context: $('#id2')})

    $("#uiLeftSidebar").sidebar('setting', 'transition', 'overlay')
    $("#uiLeftSidebar").sidebar('setting', 'dimPage', false)

    $("#uiLeftSidebar").sidebar('attach events', '#uiMenuToggle')
    $("#uiLeftSidebar").sidebar('setting', 'closable', false)

    #attach context menu events
    ContextMenu.init(Settings)
    bind_ui_actions(Settings)
    jointjs_attach_events(Obj.mainpaper, Obj.graph)


    menuview = new metabook.views.MenuView(
        el: $ ".menu"
        model: notebook
    )

bind_ui_actions = (settings) ->
    $("[data-action]").on('click', (e) ->
        action = e.target.dataset.action
        actions = Settings.ui.actions
        if `action in actions`
            ContextMenu.active_menu_off()
            actions[action].apply(this, arguments)
    )

error_graph = (e) ->
    $("#id2").dimmer('hide')
    alert("Connection error. Check if your backend is running.")
