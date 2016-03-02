init_jointjs = (obj) ->
    paper_holder = $('#paper_holder')
    graph = new joint.dia.Graph()
    paper = new joint.dia.Paper({
        el: $('#myholder'),
        width: paper_holder.width(),
        height: paper_holder.height(),
        model: graph,
        gridSize: 1
    })

    $(window).resize( ->
        #canvas = $('#modelCanvas');
        paper.setDimensions(paper_holder.width(), paper_holder.height())
    )

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


    paperscale = 1
    $('#myholder').on("mousewheel", (ev) ->
        if ev.originalEvent.deltaY < 0
            paperscale += 0.1
            paper.scale(paperscale, paperscale)
        else
            paperscale -= 0.1
            paper.scale(paperscale, paperscale)
    )



