

graphics = {}
custom_shapes = []


init_jointjs = (obj) ->
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

    paper = Obj.mainpaper
    graph = Obj.graph

    cells = obj.cells
    setting_start_x = 30
    setting_start_y = 30
    setting_increment_x = 500
    setting_increment_y = 100

    #todo
    #for cell in cells
    #    cell.


    # 1. obj is our input.
    # 2. metabook is our keys and settings
    # root: "{{root}}",
    # file_api_endpoint: "{{root}}/{{metabook_config.routes.api.file}}/",
    # file_id: "{% if 'new' in request.arguments %}{% else %}0123456789{% end %}",
    # path: "{{uri}}"
    # 3. branch for new vs saved notebook
    elements = []
    links = []

    if metabook.file_id is ""
        # new notebook
        elements.push(
            new joint.shapes.html.Node(
                position: { x: setting_start_x, y: setting_start_y }
            )
        )
    else
        prev_node = undefined
        # existing notebook
        code_cells = _.filter(obj.cells, (o) -> o['cell_type'] is "code")

        for pycell in code_cells
            node = new joint.shapes.html.Node(
                position: { x: setting_start_x, y: setting_start_y }
                content: pycell.source.join("")
                footing_content: "ipynb cell [#{pycell.execution_count}]"
                node_markup:
                    node_viewer: '<div class="node_viewer python" data-metabook="true"></div>'
                    node_editor: '<span class="ui form node_editor"><textarea class="node_coupled"></textarea></span>'
                dimensions:
                    'min-height': 100
                    'max-height': 200
                    'min-width': 250
                    'max-width': 500
                inPorts:
                    ['in:locals']
                outPorts:
                    ['out:locals']
            )



            elements.push(node)
            if prev_node
                link = new joint.shapes.html.Link(
                    source:
                        id: prev_node.id
                        port: 'out:locals'
                    target:
                        id: node.id
                        port: 'in:locals'
                )
                links.push(link)
            prev_node = node
            setting_start_x += setting_increment_x
            setting_start_y += setting_increment_y

    graph.addCells([elements..., links...])

    #$('.node_viewer').each((i, block) ->
    #    hljs.highlightBlock(block)
    #)


jointjs_attach_events = (paper, graph) ->

    selection = new Backbone.Collection
    selectionView = new joint.ui.SelectionView({ paper: paper, graph: graph, model: selection })
    paper.on('blank:pointerdown', selectionView.startSelecting)

