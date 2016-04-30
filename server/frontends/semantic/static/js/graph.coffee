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

$(document).ready ->
    WebSocketTest = undefined

    messageContainer = $(Settings.id.messages)

    WebSocketTest = (ev) ->
        messageContainer.text("WebSocket is supported by your Browser!")
        ws = new WebSocket("ws://" + window.location.host + "/api/sessions/guise?Id=123456789")

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


    # closure example
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


    # 1. Find out if we need template.
    # Two template cases: creation of new file metabook.api.file.new = true
    # or file is a raw ipynb, so metadata.metabook is undefined, will find out only after fetching the file
    data_uri = (
        ->
            if metabook.options.new is true
                # either default template or the one given by metabook.api.file.path
                if metabook.api.file.name == ""
                    # no filename so default template
                    return metabook.api.template_endpoint
                else
                    #use file as template
                    return metabook.api.file.endpoint + metabook.api.file.path
            else
                # this could be a raw ipynb or a well-formed graph, will find out after ajax request
                return metabook.api.file.endpoint + metabook.api.file.path
    )()

    #call with empty template for starters
    metabook.api.get_ajax_data(data_uri, _.partial(init_graph, {}), error_graph)

init_graph = (template, ajax_data) ->

    # find out if graph is well-formed (metadata.metabook is present).
    create_from = ""
    if not metabook.api.is_good_form(ajax_data)
        # still need to find metadata somewhere, so fetch the default template and loop back
        if Object.keys(template).length == 0
            metabook.api.get_ajax_data(metabook.api.template_endpoint, _.partial(init_graph, _, ajax_data), error_graph)
            return
        else
            create_from = "ipynb" # influences generation of control flow links
            # means even default template isn't in good form, so crash and burn
            # NOPE: means we have import from ipynb, template is good, data is bad
            # throw new Error()
    else
        if metabook.api.is_good_form(template)
            #ipynb, needs to be converted
            create_from = "ipynb" # influences generation of control flow links

        else
            # ajax_data is good form but template isn't
            # ajax_data is either proper file or template for new file
            # well-formed ajax_data, no need to apply template which is empty anyway
            create_from = "native" # no need to auto-generate control flow links

    notebook = new metabook.models.MetabookModel({}, {json: ajax_data, create_from: create_from, template: template})

    #[cells_collection, _, links] = init_jointjs(ajax_data)
    paper = init_jointjs(notebook)

    # TODO: set up long websocket server session

    notebook.session = new metabook.api.Session(metabook.api.sessions_endpoint)

    #$("[data-session]").on('click', (e) ->
    #    action = e.target.dataset.session
    #    notebook.session[action].apply(this, arguments)
    #)


    $("#id2").dimmer('hide')

    $("#uiLeftSidebar").sidebar({context: $('#id2')})

    $("#uiLeftSidebar").sidebar('setting', 'transition', 'overlay')
    $("#uiLeftSidebar").sidebar('setting', 'dimPage', false)

    $("#uiLeftSidebar").sidebar('attach events', '#uiMenuToggle')
    $("#uiLeftSidebar").sidebar('setting', 'closable', false)

    #attach context menu events
    ContextMenu.init(Settings)

    uivent = new metabook.ui.Vent()
    uivent.register({'session' : notebook.session, 'model' : notebook})

    # TODO: DEPRECATE THIS SHIT
    ###
    $("[data-action]").on('click', (e) ->
        action = e.target.dataset.action
        actions = Settings.ui.actions
        if `action in actions`
            ContextMenu.active_menu_off()
            actions[action].apply(paper, arguments)
    )
    ###

    jointjs_attach_events(paper, paper.model)


    menuview = new metabook.views.MenuView(
        el: $ ".menu"
        model: notebook
    )




error_graph = (e) ->
    $("#id2").dimmer('hide')
    alert("Connection error. Check if your backend is running.")
