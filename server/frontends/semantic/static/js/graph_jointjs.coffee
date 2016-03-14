

graphics = {}
custom_shapes = []
joint.shapes.html = {}

init_jointjs = (obj) ->
    paper_holder = $(Settings.id.graph_container)
    Settings.obj.graph = new joint.dia.Graph()
    Settings.obj.paper = new joint.dia.Paper({
        el: $(Settings.id.paper),
        width: paper_holder.width(),
        height: paper_holder.height(),
        model: Settings.obj.graph,
        gridSize: 1
    })

    paper = Settings.obj.paper
    graph = Settings.obj.graph

    extend(paper)

    $(window).resize( ->
        paper.setDimensions(paper_holder.width(), paper_holder.height())
    )

    #joint.shapes.html = {}
    joint.shapes.html.Element = joint.shapes.basic.Rect.extend(
        defaults: joint.util.deepSupplement(
            type: 'html.Element'
            attrs:
                rect: { stroke: 'none', 'fill-opacity': 0 }
            joint.shapes.basic.Rect.prototype.defaults
        )
    )

    joint.shapes.html.ElementView = joint.dia.ElementView.extend(
        template: [
            '<div style="position:absolute">',
            '<table class="ui table">',
            '<button class="ui delete button">x</button>',
            '<label class="ui label"></label>',
            '<span></span>', '<br/>',
            '<select><option>--</option><option>one</option><option>two</option></select>',
            '<input type="text" value="I\'m HTML input" />',
            '</table>',
            '</div>'
        ].join('')


        initialize: ->
            _.bindAll(this, 'updateBox')
            joint.dia.ElementView.prototype.initialize.apply(this, arguments)
            @isdraggable = false
            @dragpoint = {x: 0, y:0, paper_x:0, paper_y:0, client_x:0, client_y:0, offset_x:0, offset_y:0}

            this.$box = $(_.template(this.template)())
            #// Prevent paper from handling pointerdown.
            @$box.find('label').on 'mousedown', _.bind(((evt) ->
                evt = evt.originalEvent
                return if evt.which != 1
                @dragpoint.x = evt.pageX
                @dragpoint.y = evt.pageY
                point = Settings.obj.paper.svg.createSVGPoint().matrixTransform(Settings.obj.paper.viewport.getCTM().inverse())
                @dragpoint.offset_x = point.x * V(Settings.obj.paper.viewport).scale().sx
                @dragpoint.offset_y = point.y * V(Settings.obj.paper.viewport).scale().sy
                point2 = paper.offsetToLocalPoint(@dragpoint.x, @dragpoint.y)
                @dragpoint.paper_x = point2.x
                @dragpoint.paper_y = point2.y
                @dragpoint.client_x = @model.get('position').x
                @dragpoint.client_y = @model.get('position').y
                @isdraggable = true

                #@model.set 'position', { x: 370, y: 300}
            ), this)

            Settings.obj.paper.$el.on 'mousemove', _.bind(((evt) ->
                if @isdraggable
                    if evt.buttons != 1
                        @isdraggable = false
                        return
                    evt = evt.originalEvent
                    point = paper.offsetToLocalPoint(evt.pageX, evt.pageY)
                    #alert("ok")
                    @model.set 'position', { x: @dragpoint.client_x - @dragpoint.paper_x + point.x, y: @dragpoint.client_y - @dragpoint.paper_y + point.y}
                    #paper.setOrigin( -dragpoint.offset_x + evt.pageX - dragpoint.x, -dragpoint.offset_y + evt.pageY - dragpoint.y)
                ###
                evt = evt.originalEvent
                return if evt.which != 1
                @dragpoint.x = evt.pageX
                @dragpoint.y = evt.pageY
                point = Settings.obj.paper.svg.createSVGPoint().matrixTransform(Settings.obj.paper.viewport.getCTM().inverse())
                @dragpoint.offset_x = point.x * V(paper.viewport).scale().sx
                @dragpoint.offset_y = point.y * V(paper.viewport).scale().sy
                @paper_isdraggable = true
                #@model.set 'position', { x: 370, y: 300}
                ###
            ), this)

            $(window).on 'mouseup', _.bind(((e) ->
                @isdraggable = false
            ), this)

            @$box.find('input,select').on('mousedown click', (evt) ->
                evt.stopPropagation()
                #alert("yeah")
                )
            #// This is an example of reacting on the input change and storing the input data in the cell model.
            @$box.find('input').on 'change', _.bind(((evt) ->
                @model.set 'input', $(evt.target).val()
                return
            ), this)
            @$box.find('select').on 'change', _.bind(((evt) ->
                this.model.set 'select', $(evt.target).val()
            ), this)
            @$box.find('select').val(@model.get('select'))
            @$box.find('.delete').on('click', _.bind(@model.remove, @model))
            #// Update the box position whenever the underlying model changes.
            @model.on('change', @updateBox, this)
            #// Remove the box when the model gets removed from the graph.
            @model.on('remove', @removeBox, this)
            @updateBox()
            custom_shapes.push(this)

        render: ->
            joint.dia.ElementView.prototype.render.apply(this, arguments)
            @paper.$el.prepend(@$box)
            @updateBox()
            return this

        updateBox: ->
            #// Set the position and dimension of the box so that it covers the JointJS element.
            bbox = @model.getBBox()
            {x, y} = paper.getRealCoords(bbox.x, bbox.y)
            bbox.x = x
            bbox.y = y
            scale = paper.getScale()
            #bbox.width = bbox.width * paper.getScale()
            #bbox.height = bbox.height * paper.getScale()
            $(Settings.id.messages).text(bbox)
            #// Example of updating the HTML with a data stored in the cell model.
            @$box.find('label').text(@model.get('label'))
            @$box.find('span').text(@model.get('select'))
            @$box.css('transform-origin', 'left top')
            @$box.css({ width: bbox.width, height: bbox.height, left: bbox.x, top: bbox.y, transform: 'rotate(' + (@model.get('angle') || 0) + 'deg) scale(' + scale + ')'})

        removeBox: (evt) ->
            @$box.remove()

    )

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

    $(Settings.id.paper).on("mousewheel", (ev) ->
        ev.preventDefault()
        #Context.context.toggleMenuOff()
        ev = ev.originalEvent
        coord1 = ev.offsetX
        coord2 = ev.offsetY
        #alert(ev.wheelDelta)

        delta = 1.2
        p = paper.offsetToLocalPoint(coord1, coord2)
        #p = V(paper.viewport).toLocalPoint(coord1, coord2)
        if ev.wheelDelta < 0
            newScale = V(paper.viewport).scale().sx / delta
        else
            newScale = V(paper.viewport).scale().sx * delta


        #$(Settings.id.messages).text([V(paper.viewport).toLocalPoint(0,0).x, V(paper.viewport).toLocalPoint(0,0).y, p.x, p.y].join(", "))
        if newScale > 0.1 && newScale < 10

            paper.scale(newScale, newScale)
            paper.setOrigin(coord1 - newScale * p.x, coord2 - newScale * p.y)

        for elem in custom_shapes
            elem.updateBox()
    )
    #paper.on('cell:pointerdown', (cellView, evt, x, y) ->
    #    alert('cell view ' + cellView.model.id + ' was clicked')
    #)


    #Draggable solution
    #http://stackoverflow.com/questions/28431384/how-to-make-a-paper-draggable
    #fit to screen using flexbox
    #http://stackoverflow.com/questions/90178/make-a-div-fill-the-height-of-the-remaining-screen-space
    paper_isdraggable = false
    paper_dragpoint = {x: 0, y:0, paper_x:0, paper_y:0, client_x:0, client_y:0, offset_x:0, offset_y:0}

    #Enable pan when a blank area is click (held) on
    paper.on('blank:pointerdown', (evt, x, y) ->
        evt = evt.originalEvent
        return if evt.which != 2
        #alert(evt.which)
        paper_dragpoint.x = evt.pageX
        paper_dragpoint.y = evt.pageY
        point = paper.svg.createSVGPoint().matrixTransform(paper.viewport.getCTM().inverse())
        paper_dragpoint.offset_x = point.x * V(paper.viewport).scale().sx
        paper_dragpoint.offset_y = point.y * V(paper.viewport).scale().sy
        paper_isdraggable = true
        #$(Settings.id.messages).text('Pointer down, x:' + dragpoint.offset_x + ", y:" + dragpoint.offset_y)
    )

    $(Settings.id.paper).on("mousemove", (e) ->
        if(paper_isdraggable)
            #$(Settings.id.messages).text(e.originalEvent.pageX)
            paper.setOrigin( -paper_dragpoint.offset_x + e.pageX - paper_dragpoint.x, -paper_dragpoint.offset_y + e.pageY - paper_dragpoint.y)
            for elem in custom_shapes
                elem.updateBox()
    )

    $(window).on('mouseup', (e) ->
        paper_isdraggable = false
        $(Settings.id.messages).text('mouse up')
    )

    #//Disable pan when the mouse button is released
    paper.on('blank:pointerup', (cellView, event) ->
        paper_isdraggable = false
        $(Settings.id.messages).text('Pointer up')
    )


extend = (paper) ->
    paper.offsetToLocalPoint = (offsetX, offsetY) ->
        svgPoint = @svg.createSVGPoint()
        svgPoint.x = offsetX
        svgPoint.y = offsetY
        svgPoint.matrixTransform(@viewport.getCTM().inverse())

    paper.getScale = ->
        V(paper.viewport).scale().sx

    paper.getRealCoords = (modelX, modelY) ->
        offset = paper.svg.createSVGPoint().matrixTransform(paper.viewport.getCTM().inverse())
        x = (modelX - offset.x) * paper.getScale()
        y = (modelY - offset.y) * paper.getScale()
        return {x, y}

    paper.getModelCoords = (pageX, pageY) ->
        offset = paper.svg.createSVGPoint().matrixTransform(paper.viewport.getCTM().inverse())
        x = pageX / paper.getScale() + offset.x
        y = pageY / paper.getScale() + offset.y
        return {x, y}