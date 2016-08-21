
$(document).ready ->

    joint.shapes.html = {}
    _.extend(joint.shapes.html, require('./node'), require('./nodeview'))


    imports =
        ui: require("./ui")
        connect: require("./connect")
        data: require("./data")
        messages: require("./ui_messages")
        settings: require("./settings")
        graph: require("./graph")
        paper: require("./paper")

    _.extend(imports, require("./objects")) # imports.models, imports.views

    message = new imports.messages.SessionDisconnectedMessage(el: imports.settings.id.globalmessages)
    uivent = new imports.ui.Vent()
    uivent.register({'ui': imports.ui})

    global_gui = new imports.ui.GlobalGUI()

    session = new imports.connect.Session(config.sessions_endpoint)

    notebook = new imports.models.MetabookModel({})

    notebook.connect(session.connect_file(config.file.path))

    graph = new imports.graph({}, notebook)

    paper_holder = $(imports.settings.id.graph_container)
    mainpaper = new imports.paper({
        el: $(imports.settings.id.paper),
        width: paper_holder.width(),
        height: paper_holder.height(),
        model: graph,
        gridSize: 1
        defaultLink: new joint.shapes.html.Link
        linkPinning: false
    })
    cells = notebook.get("cells")
    links = notebook.get("links")




init_graph = (json_graph) ->

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


