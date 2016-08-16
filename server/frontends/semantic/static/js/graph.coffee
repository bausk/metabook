Settings.id =
        messages: "#messages"
        coords: "#coords"
        graph_container: "#paper_holder"
        paper: "#myholder"
        svg: "#v-2"

a = 1

$(document).ready ->


    uivent = new metabook.ui.Vent()
    uivent.register({'ui': metabook.ui})

    global_state = new state4()

    # dim the screen while fetching file data
    $("#id2").dimmer({closable:false}).dimmer('show')

    session = new metabook.connect.Session(metabook.uri.sessions_endpoint)

    session.connect_metabook(metabook.uri.file.path, init_graph)

    metabook.data.get_xhr(metabook.uri.file.endpoint + metabook.uri.file.path)
        .done( (file_json) -> init_graph(file_json) )
        .fail( error_graph )

init_graph = (json_graph) ->



    notebook = new metabook.models.MetabookModel({}, {json_graph})

    paper = init_jointjs(notebook)

    notebook.session = new metabook.connect.Session(metabook.uri.sessions_endpoint, notebook.id)

    $("#id2").dimmer('hide')

    $("#bottom_sidebar").sidebar({context: $('#id2')})

    $("#bottom_sidebar").sidebar('setting', 'transition', 'overlay')
    $("#bottom_sidebar").sidebar('setting', 'dimPage', false)

    $("#bottom_sidebar").sidebar('attach events', '#uiMenuToggle')
    $("#bottom_sidebar").sidebar('setting', 'closable', false)

    #attach context menu events
    #ContextMenu.init(Settings)


    uivent.register({'session' : notebook.session, 'model' : notebook, 'graph' : paper.model})

    jointjs_attach_events(paper, paper.model)


    menuview = new metabook.views.MenuView(
        el: $ "#metabook_top_menu"
        model: notebook
    )




error_graph = (e) ->
    $("#id2").dimmer('hide')
    alert("Connection error. Check if your backend is running.")
