paper = undefined
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
    origin = [0,0]
    #paper.setOrigin(300, 300)
    offsetToLocalPoint = (offsetX, offsetY) ->
        svgPoint = paper.svg.createSVGPoint()
        svgPoint.x = offsetX
        svgPoint.y = offsetY
        svgPoint.matrixTransform(paper.viewport.getCTM().inverse())

    $('#myholder').on("mousewheel", (ev) ->
        ev.preventDefault()
        ev = ev.originalEvent
        coord1 = ev.offsetX
        coord2 = ev.offsetY
        #alert(ev.wheelDelta)

        delta = 1.2
        p = offsetToLocalPoint(coord1, coord2)
        #p = V(paper.viewport).toLocalPoint(coord1, coord2)
        if ev.deltaY > 0
            newScale = V(paper.viewport).scale().sx / delta
        else
            newScale = V(paper.viewport).scale().sx * delta


        $('#messages').text([V(paper.viewport).toLocalPoint(0,0).x, V(paper.viewport).toLocalPoint(0,0).y, p.x, p.y].join(", "))
        if newScale > 0.1 && newScale < 10

            paper.setOrigin(0, 0)
            paper.scale(newScale, newScale, coord1, coord2)

    )

    paperscroller = new joint.ui.PaperScroller({
        paper: paper
    })

    paper.on('blank:pointerdown', paperscroller.startPanning);



