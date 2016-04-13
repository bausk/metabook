

graphics = {}
custom_shapes = []


init_jointjs = (metabook_model) ->
    paper_holder = $(Settings.id.graph_container)
    Obj.graph = new joint.dia.Graph()
    Obj.mainpaper = new GraphPaper({
        el: $(Settings.id.paper),
        width: paper_holder.width(),
        height: paper_holder.height(),
        model: Obj.graph,
        gridSize: 1
        defaultLink: new joint.shapes.html.Link
    })

    graph = Obj.graph

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
    links = metabook_model.get("metadata").metabook.links

    cells.each( (cell_model) ->
        source = cell_model.get('source')
        metadata = cell_model.get('metadata')
        id = metadata.metabook.id
        if typeof(source) != "string"
            content = source.join("")
        else
            content = source
        node = new joint.shapes.html.Node(
            id: id
            position: { x: metadata.metabook.position.x, y: metadata.metabook.position.y }
            content: content
            footing_content: "ipynb cell [#{cell_model.get('execution_count')}]"
            node_markup:
                node_viewer: '<div class="node_viewer python" data-metabook="true"></div>'
                node_editor: '<span class="ui form node_editor"><textarea class="node_coupled"></textarea></span>'
            dimensions:
                'min-height': 100
                'max-height': 200
                'min-width': 250
                'max-width': 500
            inPorts: metadata.metabook.inPorts
            outPorts: metadata.metabook.outPorts
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


jointjs_attach_events = (paper, graph) ->

    selection = new Backbone.Collection
    selectionView = new joint.ui.SelectionView({ paper: paper, graph: graph, model: selection })
    paper.on('blank:pointerdown', selectionView.startSelecting)

