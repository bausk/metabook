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

    # dim the screen while fetching file data
    $("#id2").dimmer({closable:false}).dimmer('show')

    metabook.data.get_xhr(metabook.uri.file.endpoint + metabook.uri.file.path)
        .done( (file_json) -> init_graph(file_json) )
        .fail( error_graph )

init_graph = (json_graph) ->

    notebook = new metabook.models.MetabookModel({}, {json_graph})

    paper = init_jointjs(notebook)

    notebook.session = new metabook.connect.Session(metabook.uri.sessions_endpoint)

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
