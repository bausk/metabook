init_jointjs = (obj) ->
    graph = new joint.dia.Graph()
    paper = new joint.dia.Paper({
        el: $('#myholder'),
        width: 600,
        height: 600,
        model: graph,
        gridSize: 1
    })

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