imports =
    objects: require('./objects')
    paper: require('./paper')

NodeView = joint.dia.ElementView.extend(_.extend({}, joint.shapes.basic.PortsViewInterface,
    template: [
        # Template definition.
        # <TD> structure is permanent. node_X table parts can be populated during initialize() with arbitrary content
        '<div style="position:absolute" class="node_container selection-box">'
        '<table class="ui very compact celled table node_table">'
        '<thead><tr data-metabook="node-head"><th colspan="3" class="node_head" data-content="Blergh"><%= head %></th></tr></thead>'
        '<tbody><tr class="content_row"><td class="node_empty"></td>'
        '<td class="node_content" rowspan="1"><%= node_viewer %><%= node_editor %></td>'
        '<td class="node_empty"></td></tr></tbody>'
        '<tfoot><tr><th colspan="3" class="node_footing"><%= footing %></th></tr></tfoot>'
        '</table>'
        '</div>'
    ].join('')

    content: {}

    initialize: (attributes, data) ->
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

        @$box.find('th.node_head').popup()




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

        @$box.find('.btn_close').on('click', _.bind(@model.remove, @model))

        # TODO Normal event dispatch!
        #@$box.find('[data-session]').on('click', _.bind( (evt) ->
        #    action = evt.target.dataset.session
        #    @graph.metabook.session[action](this)
        #, @model))

        @$box.find('[data-action]').on 'click', @dispatch(this)
            #custom_event = evt.target.dataset.action
            #Backbone.trigger custom_event, @
            #console.log "event triggered раз"


        #// Update the box position whenever the underlying model changes.
        @model.on('change', @updateBox, this)
        #// Remove the box when the model gets removed from the graph.
        @model.on('remove', @removeBox, this)

        #Why do we need updatebox here?
        #@updateBox()
        imports.paper.custom_shapes.push(this)

        @$box.find('.node_content').on('click', _.bind(@startEditInPlace, this))

        @$box.find('.node_head').on('dblclick', _.bind(@showDetails, this))

        #@model.on('change', @render, this)
        #@model.on 'change', _.bind(@render, this)

        # TODO: Bind handler for Extended node edition and settings


        # TODO: Bind handler for model update -> server


        #this.listenTo(@model, 'process:ports', @update)

    dispatch: (self) ->
        return (evt) ->
            custom_event = @dataset.action
            Backbone.trigger custom_event, self, evt
            console.log "<#{custom_event}>"

    render: ->
        @processPorts()
        joint.dia.ElementView.prototype.render.apply(this, arguments)
        @paper.$el.prepend(@$box) if @isrendered is false
        @updateBox()

        @isrendered = true
        # TODO: After render, reformat columns to accomodate ports correctly
        # TODO: establish event listeners for model->change:in/outPorts

        #TODO: bind context menu
        # trigger add event
        Backbone.trigger "ui:add", @
        console.log "<ui:add>"
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

        @$box.find('tbody tr').not(':first').remove()
        pairs = _.zip(@model.get('inPorts'), @model.get('outPorts'))
        rows = 1
        _.each(pairs, _.bind(
            (pair) ->
                @$box.find('tbody tr:last td').first().replaceWith("<td class='node_in'>#{pair[0] ? ""}</td>")
                $("<td class='ui node_out' data-content='fssdfsdfsdfs'>#{pair[1] ? ""}</td>").replaceAll(@$box.find('tbody tr:last td').last()).popup(
                    position: 'right center'
                )
                @$box.find('tbody tr:last').after('<tr><td class="node_empty"></td><td class="node_empty"></td></tr>')
                rows++
        , this)
        )
        @$box.find('.node_content').attr('rowspan', rows)
        @$box.find('.node_empty').on('click', _.bind(((evt) ->

            if $(evt.target).is(':last-child')
                portsname = 'outPorts'
            else
                portsname = 'inPorts'
            ports = @model.get(portsname)
            ports.push('newport' + Math.random().toPrecision(2))
            @model.set(portsname, ports)
            @model.updatePortsAttrs()
            @render()
        ), this))

    showDetails: (ev) ->
        ev.stopPropagation()
        details_modal = new imports.objects.views.DetailsView(
            el: $ "#modal_menu"
            model: @model
            template: $ "#modal_menu_template"
            )


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

        # TODO: disentangle resizing from other updates
        #// Set the position and dimension of the box so that it covers the JointJS element.
        bbox = @model.getBBox()
        {x, y} = @paper.getRealCoords(bbox.x, bbox.y)
        bbox.x = x
        bbox.y = y
        scale = @paper.current_scale

        @$box.find('label').text(@model.get('label'))
        @$box.find('span').text(@model.get('select'))
        @$box.find('.node_viewer').html(@model.get('content'))
        if @isedited is false
            @$box.find('.node_coupled').val(@model.get('content'))
        @$box.find('.content_footing').html(@model.get('footing_content'))
        @$box.css('transform-origin', 'left top')

        @$box.css({ left: bbox.x, top: bbox.y, transform: 'rotate(' + (@model.get('angle') || 0) + 'deg) scale(' + scale + ')'})

        # compute height by collecting thead+tbody height minus last tr
        height0 = parseInt(@$box.find('thead').css('height'))
        height1 = parseInt( @$box.find('tbody').css('height'))
        height2 = parseInt( @$box.find('tbody tr').last().css('height'))
        heightall = height0 + height1 - height2

        @model.set('size',
            width: parseInt(@$box.css('width'))
            height: heightall
        )
        hljs.highlightBlock(@$box.find('.node_viewer')[0])
        # @$box.css({ width: bbox.width, height: bbox.height, left: bbox.x, top: bbox.y, transform: 'rotate(' + (@model.get('angle') || 0) + 'deg) scale(' + scale + ')'})

    removeBox: (evt) ->
        @$box.remove()
)
)

class Link extends joint.dia.Link
    defaults:
        smooth: true
        type: 'html.Link',
        attrs: { '.connection': { 'stroke-width': 4, stroke: '#a0a0a9' } }

module.exports = {NodeView, Link}