func_add = (e) ->
    alert("add")

func_edit = (e) ->
    alert("edit")

func_delete = (e) ->
    alert("delete" + e.pageX)

Settings =
    active_menu_class: "context-menu--active"
    context_menu:
        ".element": "#context-menu"
        "svg": "#context-menu2"
    ui_actions:
        "Add": func_add
        "Edit": func_edit
        "Delete": func_delete
    id:
        messages: "#messages"
        graph_container: "#paper_holder"
        paper: "#myholder"
        svg: "#v-2"
    obj:
        paper: undefined
        graph: undefined

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


    # if file is new, generate ID I guess...
    # TODO
    if metabook.file_id == ""
        init_graph( {} )
    else
        $.ajax(
            url: metabook.file_api_endpoint + metabook.path
            type: 'GET'
            success: init_graph
            error: error_graph
        )

init_graph = (graph_json) ->
    $("#el_file_contents").text(graph_json)
    source_obj = graph_json
    init_jointjs(source_obj)

    $("#id2").dimmer('hide')

    $("#uiLeftSidebar").sidebar({context: $('#id2')})

    $("#uiLeftSidebar").sidebar('setting', 'transition', 'overlay')
    $("#uiLeftSidebar").sidebar('setting', 'dimPage', false)

    $("#uiLeftSidebar").sidebar('attach events', '#uiMenuToggle')
    $("#uiLeftSidebar").sidebar('setting', 'closable', false)

    #attach context menu events
    ContextMenu.init(Settings)
    bind_ui_actions(Settings)
    jointjs_attach_events(Settings.obj.paper, Settings.obj.graph)

bind_ui_actions = (settings) ->
    $("[data-action]").on('click', (e) ->
        action = e.target.dataset.action
        actions = settings.ui_actions
        if `action in actions`
            ContextMenu.active_menu_off()
            actions[action].apply(this, arguments)
    )

error_graph = (e) ->
    $("#id2").dimmer('hide')
    alert("fuck u mimsy")
