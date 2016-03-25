
joint.shapes.html.Node = joint.shapes.basic.Generic.extend(_.extend(
    {},
    joint.shapes.basic.PortsModelInterface,
        markup: '<g class="rotatable"><g class="scalable"><rect class="body"/></g><text class="label"/><g class="inPorts"/><g class="outPorts"/></g>',
        portMarkup: '<g class="port port<%= id %>"><circle class="port-body"/></g>',

        defaults: joint.util.deepSupplement({

            type: 'html.Node'
            size: { width: 350, height: 100 }
            inPorts: ['In[0]']
            outPorts: ['Out[0]']

            attrs:

                rect:
                    stroke: 'none'
                    fill: 'transparent'
                    'stroke-opacity': 0
                    'fill-opacity': 0
                '.':
                    magnet: false
                '.body':
                    width: 150, height: 150
                    stroke: '#000000'
                '.port-body':
                    r: 10
                    magnet: true
                    stroke: '#000000'
                text:
                    'pointer-events': 'none'
                '.label':
                    text: 'Model', 'ref-x': .5, 'ref-y': 10, ref: '.body', 'text-anchor': 'middle', fill: '#000000'
                '.inPorts .port-label':
                    x:-15, dy: 4, 'text-anchor': 'end', fill: '#000000'
                '.outPorts .port-label':
                    x: 15, dy: 4, fill: '#000000'
                '.inPorts circle': { fill: '#666666', 'stroke-opacity': 0  }
                '.outPorts circle': { fill: '#999999', 'stroke-opacity': 0 }
                '.inPorts .port-body': fill: '#333333'
                '.outPorts .port-body': fill: '#666666'

            head_content: 'Cell: ID'
            content: 'Click to edit code'
            footing_content: 'Version A4D3E453'
            node_markup:
                    head: '<span class="content_head">Code Cell: FGFDG3456FGDFE<label class="ui very small label btn_close"><span class="fa fa-close"></span></label></span>'
                    node_viewer: '<div class="node_viewer"></div>'
                    node_editor: '<span class="ui form node_editor"><textarea class="node_coupled"></textarea></span>'
                    footing: '<span class="ui small label content_footing" style="font-family: monospace">Python file</span>'

        }, joint.shapes.basic.Generic.prototype.defaults),
        getPortAttrs: (portName, index, total, selector, type) ->

            attrs = {}
            portClass = 'port' + index
            portSelector = selector + '>.' + portClass
            portLabelSelector = portSelector + '>.port-label'
            portBodySelector = portSelector + '>.port-body'

            attrs[portLabelSelector] = { text: portName }
            attrs[portBodySelector] =
                port:
                    id: portName || _.uniqueId(type)
                    type: type
            attrs[portSelector] = { ref: '.body', 'ref-y': (index + 0.5) * (1 / total) }
            if selector is '.outPorts'
                attrs[portSelector]['ref-dx'] = 0
            return attrs
    )
)

joint.shapes.html.NodeView = joint.dia.ElementView.extend(_.extend({}, joint.shapes.basic.PortsViewInterface,
    template: [
        # Template definition.
        # <TD> structure is permanent. node_X table parts can be populated during initialize() with arbitrary content
        '<div style="position:absolute" class="node_container">'
        '<table class="ui very compact celled table node_table">'
        '<thead><tr data-metabook="node-head"><th colspan="3" class="node_head"><%= head %></th></tr></thead>'
        '<tbody><tr class="content_row"><td class="node_empty"></td>'
        '<td class="node_content" rowspan="1"><%= node_viewer %><%= node_editor %></td>'
        '<td class="node_empty"></td></tr></tbody>'
        '<tfoot><tr><th colspan="3" class="node_footing"><%= footing %></th></tr></tfoot>'
        '</table>'
        '</div>'
    ].join('')

    content: {}

    initialize: ->
        #_.bindAll is prolly not needed
        #_.bindAll(this, 'updateBox')
        joint.dia.ElementView.prototype.initialize.apply(this, arguments)
        @isdraggable = false
        @isedited = false
        @isrendered = false
        @dragpoint = {x: 0, y:0, paper_x:0, paper_y:0, client_x:0, client_y:0, offset_x:0, offset_y:0}

        @$box = $(_.template(@template)(@model.get('node_markup')))

        # hide node editor
        @$box.find('.node_editor').addClass('invisible')

        # dimensioning
        @$box.find('.node_viewer').css(@model.get('dimensions'))

        #// Prevent paper from handling pointerdown.
        @$box.find('th.node_head').on 'mousedown', _.bind(((evt) ->
            evt = evt.originalEvent
            return if evt.which != 1
            @dragpoint.x = evt.pageX
            @dragpoint.y = evt.pageY
            point = @paper.origin
            @dragpoint.offset_x = point.x * @paper.scale
            @dragpoint.offset_y = point.y * @paper.scale
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
        ), this)

        $(window).on 'mouseup', _.bind(((e) ->
            @isdraggable = false
        ), this)


        #
        # TODO: Reactions towards different clicks and mouseovers. Examples provided below
        #

        ###
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
        ###
        @$box.find('.btn_close').on('click', _.bind(@model.remove, @model))

        #// Update the box position whenever the underlying model changes.
        @model.on('change', @updateBox, this)
        #// Remove the box when the model gets removed from the graph.
        @model.on('remove', @removeBox, this)



        #Why do we need updatebox here?
        #@updateBox()
        custom_shapes.push(this)

        @$box.find('.node_content').on('click', _.bind(@startEditInPlace, this))

        @model.on 'change:inPorts change:outPorts', _.bind(@render, this)

        #this.listenTo(@model, 'process:ports', @update)
        ##joint.dia.ElementView.prototype.initialize.apply(this, arguments)


    render: ->
        @processPorts()
        joint.dia.ElementView.prototype.render.apply(this, arguments)
        @paper.$el.prepend(@$box) if @isrendered is false
        @updateBox()
        @isrendered = true
        # TODO: After render, reformat columns to accomodate ports correctly
        # TODO: establish event listeners for model->change:in/outPorts


        return this

    ###    update: ->

            #// First render ports so that `attrs` can be applied to those newly created DOM elements
            #// in `ElementView.prototype.update()`.
            this.renderPorts()
            joint.dia.ElementView.prototype.update.apply(this, arguments)

        renderPorts: ->

            $inPorts = @$('.inPorts').empty()
            $outPorts = @$('.outPorts').empty()

            portTemplate = _.template(@model.portMarkup)

            _.each(_.filter(@model.ports, (p) -> return p.type is 'in'), (port, index) ->
                $inPorts.append(V(portTemplate({ id: index, port: port })).node)
            )
            _.each(_.filter(@model.ports, (p) -> return p.type is 'out'), (port, index) ->
                $outPorts.append(V(portTemplate({ id: index, port: port })).node);
            )
    ###

    processPorts: ->
        # 1) find and save filler cells .node_empty in the bottom row
        # 2) remove all rows except first
        # 3) with one row remaining, populate two edge cells with data about ports and create next table row
        # 4) the last row created in the loop is the emtpy filler
        # 5) set correct rowspan of the central element, .node_content

        $filler_cells = @$box.find('td.node_empty').clone()
        @$box.find('tbody tr').not(':first').remove()
        pairs = _.zip(@model.get('inPorts'), @model.get('outPorts'))
        rows = 1
        _.each(pairs, _.bind(
            (pair) ->
                @$box.find('tbody tr:last td').first().replaceWith("<td class='node_in'>#{pair[0] ? ""}</td>")
                @$box.find('tbody tr:last td').last().replaceWith("<td class='node_out'>#{pair[1] ? ""}</td>")
                @$box.find('tbody tr:last').after('<tr><td class="node_empty"></td><td class="node_empty"></td></tr>')
                rows++
        , this)
        )
        @$box.find('.node_content').attr('rowspan', rows)


    startEditInPlace: ->
        @$box.find('.node_viewer').addClass('invisible')
        @$box.find('.node_coupled').css('width', parseInt(@$box.find('.node_viewer').css('width')) + 6)
        @$box.find('.node_coupled').css('height', parseInt(@$box.find('.node_viewer').css('height')) + 6)
        @$box.find('.node_editor').removeClass('invisible').find('.node_coupled').focus()
        @isedited = true
        @$box.find('.node_editor').on('mousemove', (evt) ->
            evt.stopPropagation()
        )

        @$box.find('.node_coupled').on('keydown', _.bind( ((evt) ->
            if evt.keyCode is 27
                @isedited = false
                @$box.find('.node_coupled').blur()
                # escape
            if evt.keyCode is 13 and evt.ctrlKey is true
                @$box.find('.node_coupled').blur()


            ), this)
        )


        # Automatic resizing
        # solution more or less taken from http://jsfiddle.net/buM6M/228/
        @$box.find('.node_coupled').on('keyup', _.bind( ((evt) ->
            textarea = @$box.find('.node_coupled')
            view = @$box.find('.node_viewer')
            newcontent = textarea.val()
            view.html(newcontent)
            textarea.css('width', parseInt(view.css('width')) + 6)
            textarea.css('height', parseInt(view.css('height')) + 6)
            ), this)
        )


        @$box.find('.node_coupled').on('mousewheel', _.bind(((evt) ->
            evt.stopPropagation()
            ), this)
        )

        @$box.find('.node_coupled').on('blur', _.bind( ((evt) ->
            textarea = @$box.find('.node_coupled')
            view = @$box.find('.node_viewer')
            newcontent = textarea.val()
            if @isedited is true
                @model.set('content', newcontent)
                view.html(newcontent)

            @isedited = false




            @$box.find('.node_editor').addClass('invisible')
            @$box.find('.node_viewer').removeClass('invisible')


            @updateBox()
            ), this)
        )

        #@$box.find('.node_editor').on('click', (evt) ->
        #    evt.stopPropagation()

        #)
        #@$box.find('.content_node').focusout( _.bind(( ->
        #    @$box.find('.content_node').replaceWith(@model.get('metabook').markup.node
        #    )), this)
        #)



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
        @$box.find('.node_viewer').html(@model.get('content'))
        if @isedited is false
            @$box.find('.node_coupled').val(@model.get('content'))
        @$box.find('.content_footing').html(@model.get('footing_content'))
        @$box.css('transform-origin', 'left top')
        # TODO: invert update to make model dependent on @$box size
        @$box.css({ left: bbox.x, top: bbox.y, transform: 'rotate(' + (@model.get('angle') || 0) + 'deg) scale(' + scale + ')'})
        @model.set('size',
            width: parseInt(@$box.css('width'))
            height: parseInt(@$box.css('height'))
        )
        hljs.highlightBlock(@$box.find('.node_viewer')[0])
        # @$box.css({ width: bbox.width, height: bbox.height, left: bbox.x, top: bbox.y, transform: 'rotate(' + (@model.get('angle') || 0) + 'deg) scale(' + scale + ')'})

    removeBox: (evt) ->
        @$box.remove()
)
)

class joint.shapes.html.Link extends joint.dia.Link
    defaults:
        smooth: true
        type: 'html.Link',
        attrs: { '.connection': { 'stroke-width': 4, stroke: '#a0a0a9' } }
###
joint.shapes.html.Link = joint.dia.Link.extend({

    defaults: {
        smooth: true
        type: 'html.Link',
        attrs: { '.connection': { 'stroke-width': 5, stroke: '#a0a0a9' } }
    }
})

###