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

        #Enable pan when a blank area is click (held) on
        @on('blank:pointerdown', (evt, x, y) ->
            evt = evt.originalEvent
            return if evt.which != 2
            @dragpoint.x = evt.pageX
            @dragpoint.y = evt.pageY
            @dragpoint.offset_x = @origin.x * @current_scale
            @dragpoint.offset_y = @origin.y * @current_scale
            @draggable = true
        )

        @$el.on("mousewheel", _.bind(((ev) ->
            ev.preventDefault()
            #Context.context.toggleMenuOff()
            ev = ev.originalEvent
            coord1 = ev.offsetX
            coord2 = ev.offsetY
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
        #_.bindAll is prolly not needed
        #_.bindAll(this, 'updateBox')
        joint.dia.ElementView.prototype.initialize.apply(this, arguments)
        @isdraggable = false
        @dragpoint = {x: 0, y:0, paper_x:0, paper_y:0, client_x:0, client_y:0, offset_x:0, offset_y:0}

        # TODO

        @$box = $(_.template(this.template)())
        #// Prevent paper from handling pointerdown.
        @$box.find('label').on 'mousedown', _.bind(((evt) ->
            evt = evt.originalEvent
            return if evt.which != 1
            @dragpoint.x = evt.pageX
            @dragpoint.y = evt.pageY
            point = @paper.svg.createSVGPoint().matrixTransform(@paper.viewport.getCTM().inverse())
            @dragpoint.offset_x = point.x * V(@paper.viewport).scale().sx
            @dragpoint.offset_y = point.y * V(@paper.viewport).scale().sy
            point2 = @paper.offsetToLocalPoint(@dragpoint.x, @dragpoint.y)
            @dragpoint.paper_x = point2.x
            @dragpoint.paper_y = point2.y
            @dragpoint.client_x = @model.get('position').x
            @dragpoint.client_y = @model.get('position').y
            @isdraggable = true
        ), this)

        #Drag behavior
        $(window).on 'mousemove', _.bind(((evt) ->
            if @isdraggable
                if evt.buttons != 1
                    @isdraggable = false
                    return
                evt = evt.originalEvent
                point = @paper.offsetToLocalPoint(evt.pageX, evt.pageY)
                #alert("ok")
                @model.set 'position', { x: @dragpoint.client_x - @dragpoint.paper_x + point.x, y: @dragpoint.client_y - @dragpoint.paper_y + point.y}
                #paper.setOrigin( -dragpoint.offset_x + evt.pageX - dragpoint.x, -dragpoint.offset_y + evt.pageY - dragpoint.y)
            ###
            evt = evt.originalEvent
            return if evt.which != 1
            @dragpoint.x = evt.pageX
            @dragpoint.y = evt.pageY
            point = Obj.mainpaper.svg.createSVGPoint().matrixTransform(Obj.mainpaper.viewport.getCTM().inverse())
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

        #Why do we need updatebox here?
        #@updateBox()
        custom_shapes.push(this)

    render: ->
        joint.dia.ElementView.prototype.render.apply(this, arguments)
        @paper.$el.prepend(@$box)
        @updateBox()
        return this

    updateBox: ->
        #// Set the position and dimension of the box so that it covers the JointJS element.
        bbox = @model.getBBox()
        {x, y} = @paper.getRealCoords(bbox.x, bbox.y)
        bbox.x = x
        bbox.y = y
        scale = @paper.current_scale
        #bbox.width = bbox.width * paper.getScale()
        #bbox.height = bbox.height * paper.getScale()
        $(Settings.id.messages).text(bbox.x + "//" + bbox.y)
        #// Example of updating the HTML with a data stored in the cell model.
        @$box.find('label').text(@model.get('label'))
        @$box.find('span').text(@model.get('select'))
        @$box.css('transform-origin', 'left top')
        @$box.css({ width: bbox.width, height: bbox.height, left: bbox.x, top: bbox.y, transform: 'rotate(' + (@model.get('angle') || 0) + 'deg) scale(' + scale + ')'})

    removeBox: (evt) ->
        @$box.remove()

)
