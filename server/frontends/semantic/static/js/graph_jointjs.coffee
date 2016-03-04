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

            paper.scale(newScale, newScale)
            paper.setOrigin(coord1 - newScale * p.x, coord2 - newScale * p.y)
    )

    ###
    panAndZoom = svgPanZoom(
        '#v-2',
        {
            #viewportSelector: $('#v-2'),
            fit: false,
            zoomScaleSensitivity: 0.4,
            #panEnabled: false,
            #zoomEnabled: false
        }
    )

###
    draggable = false
    dragpoint = {x: 0, y:0, paper_x:0, paper_y:0, client_x:0, client_y:0, offset_x:0, offset_y:0}

    #Enable pan when a blank area is click (held) on
    paper.on('blank:pointerdown', (evt, x, y) ->
        evt = evt.originalEvent
        #return if evt.which != 2
        #alert(evt.which)
        dragpoint.x = evt.pageX
        dragpoint.y = evt.pageY
        point = paper.svg.createSVGPoint().matrixTransform(paper.viewport.getCTM().inverse())
        dragpoint.offset_x = point.x * V(paper.viewport).scale().sx
        dragpoint.offset_y = point.y * V(paper.viewport).scale().sy
        draggable = true
        $("#messages").text('Pointer down, x:' + dragpoint.offset_x + ", y:" + dragpoint.offset_y)

    )

    $("#paper_holder").on("mousemove", (e) ->
        if(draggable)
            $("#messages").text(e.originalEvent.pageX)
            paper.setOrigin( -dragpoint.offset_x + e.pageX - dragpoint.x, -dragpoint.offset_y + e.pageY - dragpoint.y)
    )

    $(window).on('mouseup', (e) ->
        draggable = false
        $("#messages").text('mouse up')
    )

    #//Disable pan when the mouse button is released
    paper.on('blank:pointerup', (cellView, event) ->
        draggable = false
        $("#messages").text('Pointer up')
    )



