# SelectionView
# =============
# `SelectionView` implements selecting group of elements and moving the selected elements in one go.
# Typically, the selection will be bound to the `Shift` key
# and selecting/deselecting individual elements to the `Ctrl` key.
# Example usage:
# var graph = new joint.dia.Graph;
# var paper = new joint.dia.Paper({ model: graph });
# var selection = new Backbone.Collection;
# var selectionView = new joint.ui.SelectionView({ paper: paper, graph: graph, model: selection });
# // Bulk selecting group of elements by creating a rectangular selection area.
# paper.on('blank:pointerdown', selectionView.startSelecting);
# // Selecting individual elements with click and the `Ctrl`/`Command` key.
# paper.on('cell:pointerup', function(cellView, evt) {
#            if ((evt.ctrlKey || evt.metaKey) && !(cellView.model instanceof joint.dia.Link)) {
#                            selectionView.createSelectionBox(cellView);
#                            selection.add(cellView.model);
#            }
# });
# // Deselecting previously selected elements with click and the `Ctrl`/`Command` key.
# selectionView.on('selection-box:pointerdown', function(evt) {
#            if (evt.ctrlKey || evt.metaKey) {
#                            var cell = selection.get($(evt.target).data('model'));
#                            selectionView.destroySelectionBox(paper.findViewByModel(cell));
#                            selection.reset(selection.without(cell));
#            }
# });
joint.ui.SelectionView = Backbone.View.extend(
    options:
        paper: undefined
        graph: undefined
    className: 'selection'
    events: 'mousedown .selection-box': 'startTranslatingSelection'
    initialize: (options) ->
        @options = options
        _.bindAll this, 'startSelecting', 'stopSelecting', 'adjustSelection'
        $(document.body).on 'mouseup touchend', @stopSelecting
        $(document.body).on 'mousemove touchmove', @adjustSelection
        @options.paper.$el.append @$el
        return
    startTranslatingSelection: (evt) ->
        @_action = 'translating'
        @options.graph.trigger 'batch:start'
        snappedClientCoords = @options.paper.snapToGrid(g.point(evt.clientX, evt.clientY))
        @_snappedClientX = snappedClientCoords.x
        @_snappedClientY = snappedClientCoords.y
        @trigger 'selection-box:pointerdown', evt
        evt.stopPropagation()
        return
    startSelecting: (evt, x, y) ->
        if evt.originalEvent.which == 2 or evt.originalEvent.which == 3
            return
        @$el.removeClass 'selected'
        @$el.empty()
        @model.reset []
        @_action = 'selecting'
        @_clientX = evt.clientX
        @_clientY = evt.clientY
        # Normalize `evt.offsetX`/`evt.offsetY` for browsers that don't support it (Firefox).
        paperElement = evt.target.parentElement or evt.target.parentNode
        paperOffset = $(paperElement).offset()
        paperScrollLeft = paperElement.scrollLeft
        paperScrollTop = paperElement.scrollTop
        @_offsetX = if evt.offsetX == undefined then evt.clientX - (paperOffset.left) + window.pageXOffset + paperScrollLeft else evt.offsetX
        @_offsetY = if evt.offsetY == undefined then evt.clientY - (paperOffset.top) + window.pageYOffset + paperScrollTop else evt.offsetY
        @$el.css(
            width: 1
            height: 1
            left: @_offsetX
            top: @_offsetY).show()
        return
    adjustSelection: (evt) ->
        dx = undefined
        dy = undefined
        switch @_action
            when 'selecting'
                dx = evt.clientX - (@_clientX)
                dy = evt.clientY - (@_clientY)
                width = @$el.width()
                height = @$el.height()
                left = parseInt(@$el.css('left'), 10)
                top = parseInt(@$el.css('top'), 10)
                @$el.css
                    left: if dx < 0 then @_offsetX + dx else left
                    top: if dy < 0 then @_offsetY + dy else top
                    width: Math.abs(dx)
                    height: Math.abs(dy)
            when 'translating'
                snappedClientCoords = @options.paper.snapToGrid(g.point(evt.clientX, evt.clientY))
                snappedClientX = snappedClientCoords.x
                snappedClientY = snappedClientCoords.y
                dx = snappedClientX - (@_snappedClientX)
                dy = snappedClientY - (@_snappedClientY)
                # This hash of flags makes sure we're not adjusting vertices of one link twice.
                # This could happen as one link can be an inbound link of one element in the selection
                # and outbound link of another at the same time.
                processedLinks = {}
                @model.each ((element) ->
                    # TODO: snap to grid.
                    # Translate the element itself.
                    element.translate dx, dy
                    # Translate link vertices as well.
                    connectedLinks = @options.graph.getConnectedLinks(element)
                    _.each connectedLinks, (link) ->
                        if processedLinks[link.id]
                            return
                        vertices = link.get('vertices')
                        if vertices and vertices.length
                            newVertices = []
                            _.each vertices, (vertex) ->
                                newVertices.push
                                    x: vertex.x + dx
                                    y: vertex.y + dy
                                return
                            link.set 'vertices', newVertices
                        processedLinks[link.id] = true
                        return
                    return
                ), this
                if dx or dy
                    paperScale = V(@options.paper.viewport).scale()
                    dx *= paperScale.sx
                    dy *= paperScale.sy
                    # Translate also each of the `selection-box`.
                    @$('.selection-box').each ->
                        `var top`
                        `var left`
                        left = parseFloat($(this).css('left'), 10)
                        top = parseFloat($(this).css('top'), 10)
                        $(this).css
                            left: left + dx
                            top: top + dy
                        return
                    @_snappedClientX = snappedClientX
                    @_snappedClientY = snappedClientY
        return
    stopSelecting: ->
        switch @_action
            when 'selecting'
                offset = @$el.offset()
                width = @$el.width()
                height = @$el.height()
                # Convert offset coordinates to the local point of the <svg> root element.
                localPoint = V(@options.paper.svg).toLocalPoint(offset.left, offset.top)
                # Take page scroll into consideration.
                localPoint.x -= window.pageXOffset
                localPoint.y -= window.pageYOffset
                elementViews = @options.paper.findViewsInArea(g.rect(localPoint.x, localPoint.y, width, height))
                if elementViews.length
                    # Create a `selection-box` `<div>` for each element covering its bounding box area.
                    _.each elementViews, @createSelectionBox, this
                    # The root element of the selection switches `position` to `static` when `selected`. This
                    # is neccessary in order for the `selection-box` coordinates to be relative to the
                    # `paper` element, not the `selection` `<div>`.
                    @$el.addClass 'selected'
                else
                    # Hide the selection box if there was no element found in the area covered by the
                    # selection box.
                    @$el.hide()
                @model.reset _.pluck(elementViews, 'model')
            when 'translating'
                @options.graph.trigger 'batch:stop'
                # Everything else is done during the translation.
            when 'cherry-picking'
                # noop;    All is done in the `createSelectionBox()` function.
                # This is here to avoid removing selection boxes as a reaction on mouseup event and
                # propagating to the `default` branch in this switch.
            else
                # Hide selection if the user clicked somehwere else in the document.
                @$el.hide().empty()
                @model.reset []
                break
        delete @_action
        return
    cancelSelection: ->
        @$('.selection-box').remove()
        @$el.hide().removeClass 'selected'
        @model.reset []
        return
    destroySelectionBox: (elementView) ->
        @$('[data-model="' + elementView.model.get('id') + '"]').remove()
        if @$('.selection-box').length == 0
            @$el.hide().removeClass 'selected'
        return
    createSelectionBox: (elementView) ->
        viewBbox = elementView.getBBox()
        $selectionBox = $('<div/>',
            'class': 'selection-box'
            'data-model': elementView.model.get('id'))
        $selectionBox.css
            left: viewBbox.x
            top: viewBbox.y
            width: viewBbox.width
            height: viewBbox.height
        @$el.append $selectionBox
        @$el.addClass('selected').show()
        @_action = 'cherry-picking'
        return
)
