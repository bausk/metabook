

graphics = {}
custom_shapes = []


init_jointjs = (metabook_model) ->
    paper_holder = $(Settings.id.graph_container)
    graph = new metabook.MetaGraph({}, metabook_model)

    mainpaper = new GraphPaper({
        el: $(Settings.id.paper),
        width: paper_holder.width(),
        height: paper_holder.height(),
        model: graph,
        gridSize: 1
        defaultLink: new joint.shapes.html.Link
        linkPinning: false
    })

    # 1. obj is our input.
    # 2. metabook is our keys and settings
    # root: "{{root}}",
    # file_api_endpoint: "{{root}}/{{metabook_config.routes.api.file}}/",
    # file_id: "{% if 'new' in request.arguments %}{% else %}0123456789{% end %}",
    # path: "{{uri}}"
    # 3. branch for new vs saved notebook
    elems_list = []
    links_list = []

    cells = metabook_model.get("cells")
    links = metabook_model.get("links")

    cells.each( (cell_model) ->
        source = cell_model.get('source')
        id = cell_model.id
        if typeof(source) != "string"
            content = source.join("")
        else
            content = source
        position = cell_model.get('position')
        node = new joint.shapes.html.Node(
            id: id
            position: { x: position.x, y: position.y }
            content: content
            footing_content: "[ipynb cell]"
            node_markup:
                node_viewer: '<div class="node_viewer python" data-metabook="true"></div>'
                node_editor: '<span class="ui form node_editor"><textarea class="node_coupled"></textarea></span>'
            dimensions:
                'min-height': 100
                'max-height': 200
                'min-width': 250
                'max-width': 500
            inPorts: cell_model.get('inPorts')
            outPorts: cell_model.get('outPorts')
        , {cell_model}
        )
        elems_list.push(node)
    )

    links.each( (link_model) ->
        link = new joint.shapes.html.Link(
            source: link_model.get('source')
            target: link_model.get('target')
            id: link_model.get('id')
        )
        links_list.push(link)
    )

    graph.addCells([elems_list..., links_list...])

    #return [cell_collection, elements, links]

    #$('.node_viewer').each((i, block) ->
    #    hljs.highlightBlock(block)
    #)
    return mainpaper

jointjs_attach_events = (paper, graph) ->

    selection = new Backbone.Collection
    selectionView = new joint.ui.SelectionView({ paper: paper, graph: graph, model: selection })
    paper.on('blank:pointerdown', selectionView.startSelecting)

    paper.on('blank:contextmenu', (e) ->
        custom_event = "ui:blankmenu"
        metabook.ui.Vent.vent custom_event, @, e
    )
