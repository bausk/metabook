
$(document).ready ->

    imports =
        ui: require("./ui")
        connect: require("./connect")
        data: require("./data")
        messages: require("./ui_messages")
        settings: require("./settings")

    _.extend(imports, require("./objects")) # imports.models, imports.views

    message = new imports.messages.SessionDisconnectedMessage(el: imports.settings.id.globalmessages)
    uivent = new imports.ui.Vent()
    uivent.register({'ui': imports.ui})

    global_gui = new imports.ui.GlobalGUI()

    session = new imports.connect.Session(config.sessions_endpoint)

    notebook = new imports.models.MetabookModel({})

    notebook.connect(session.connect_file(config.file.path))

    paper = init_jointjs(notebook)


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


