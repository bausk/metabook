joint.shapes.html = {}

GraphPaper = joint.dia.Paper.extend(

    origin:
        x: 0
        y: 0
    current_scale: 1

    #Draggable solution
    #http://stackoverflow.com/questions/28431384/how-to-make-a-paper-draggable
    #fit to screen using flexbox
    #http://stackoverflow.com/questions/90178/make-a-div-fill-the-height-of-the-remaining-screen-space
    draggable: false
    dragpoint: {x: 0, y:0, offset_x:0, offset_y:0}

    initialize: ->

        joint.dia.Paper.prototype.initialize.apply(this, arguments)
        #_.bindAll is prolly not needed
        _.bindAll(this, 'offsetToLocalPoint', 'updateOrigin', 'updateScale', 'getRealCoords')
        @updateOrigin()
        @updateScale()

        $(window).resize( _.bind(( ->
            @setDimensions(@$el.width(), @$el.height())
        ), this)
        )

        @on('cell:pointerdown cell:mouseover', (cellView, evt, x, y) ->
            if $(evt.target).parent().hasClass("link")
                cellView.options.interactive = false
        )

        @on('all', (evt, x, y) ->
            console.log(evt)
        )

        #Enable pan when a /blank/ not blank, any area is click (held) on
        @$el.on('mousedown', _.bind(((evt, x, y) ->
            evt = evt.originalEvent
            return if evt.which != 2
            evt.preventDefault()
            @dragpoint.x = evt.pageX
            @dragpoint.y = evt.pageY
            @dragpoint.offset_x = @origin.x * @current_scale
            @dragpoint.offset_y = @origin.y * @current_scale
            @draggable = true
        ), this)
        )




        @$el.on("mousewheel", _.bind(((ev) ->
            ev.preventDefault()
            #Context.context.toggleMenuOff()
            ev = ev.originalEvent

            coord1 = $(ev.target).offset().left + ev.offsetX - @$el.offset().left
            coord2 = $(ev.target).offset().top + ev.offsetY - @$el.offset().top
            #alert(ev.wheelDelta)
            delta = 1.2
            p = @offsetToLocalPoint(coord1, coord2)
            #p = V(paper.viewport).toLocalPoint(coord1, coord2)
            if ev.wheelDelta < 0
                newScale = @current_scale / delta
            else
                newScale = @current_scale * delta

            if newScale > 0.1 && newScale < 10
                @scale(newScale, newScale)
                @setOrigin(coord1 - newScale * p.x, coord2 - newScale * p.y)
                @updateScale()
                @updateOrigin()

                #cells = paper.model.getCells()
                #for cell in cells
                #    cell.set('a', 1)

                for elem in custom_shapes
                    elem.updateBox()
        ), this)
        )

        #pan event
        @$el.on("mousemove", _.bind(((e) ->
            if(@draggable)
                @setOrigin( -@dragpoint.offset_x + e.pageX - @dragpoint.x, -@dragpoint.offset_y + e.pageY - @dragpoint.y)
                @updateOrigin()
                for elem in custom_shapes
                    elem.updateBox()
        ), this)
        )
        #end panning
        $(window).on('mouseup', (e) ->
            @draggable = false
            #$(Settings.id.messages).text('mouse up')
        )

        #//Disable pan when the mouse button is released
        @on('blank:pointerup', (cellView, event) ->
            @draggable = false
            #$(Settings.id.messages).text('Pointer up')
        )


    offsetToLocalPoint: (offsetX, offsetY) ->
        svgPoint = @svg.createSVGPoint()
        svgPoint.x = offsetX
        svgPoint.y = offsetY
        svgPoint.matrixTransform(@viewport.getCTM().inverse())

    updateScale: ->
        @current_scale = V(@viewport).scale().sx

    updateOrigin: ->
        @origin = @svg.createSVGPoint().matrixTransform(@viewport.getCTM().inverse())

    getRealCoords: (modelX, modelY) ->
        offset = @origin
        x = (modelX - offset.x) * @current_scale
        y = (modelY - offset.y) * @current_scale
        $(Settings.id.coords).text(modelX + ":" + modelY + "/" + x + ":" + y)
        return {x, y}

    getModelCoords: (pageX, pageY) ->
        offset = @origin
        x = pageX / @current_scale + offset.x
        y = pageY / @current_scale + offset.y
        return {x, y}
)
