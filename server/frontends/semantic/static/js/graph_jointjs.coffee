

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
    })

    paper = Obj.mainpaper
    graph = Obj.graph

    cells = obj.cells
    setting_start_x = 30
    setting_start_y = 30
    setting_increment_x = 200
    setting_increment_y = 100

    #todo
    #for cell in cells
    #    cell.
    el1 = new joint.shapes.html.Element({ position: { x: 80, y: 80 }, size: { width: 170, height: 100 }, label: 'I am HTML', select: 'one' })
    el2 = new joint.shapes.html.Element({ position: { x: 370, y: 160 }, size: { width: 170, height: 100 }, label: 'Me too', select: 'two' })
    #custom_shapes.push(el1, el2)
    l = new joint.dia.Link({
        source: { id: el1.id },
        target: { id: el2.id },
        attrs: { '.connection': { 'stroke-width': 5, stroke: '#34495E' } }
    })

    graph.addCells([el1, el2, l])


    ###
    rect = new joint.shapes.basic.Rect({
        position: { x: 100, y: 30 },
        size: { width: 100, height: 30 },
        attrs: { rect: { fill: "blue" }, text: { text: 'my box', fill: 'white' } }
    })

    rect2 = rect.clone()
    rect2.translate(300)
    link = new joint.dia.Link({
        source: { id: rect.id },
        target: { id: rect2.id }
    })

    graph.addCells([rect, rect2, link])
    ###


jointjs_attach_events = (paper, graph) ->

    selection = new Backbone.Collection
    selectionView = new joint.ui.SelectionView({ paper: paper, graph: graph, model: selection })
    paper.on('blank:pointerdown', selectionView.startSelecting)

