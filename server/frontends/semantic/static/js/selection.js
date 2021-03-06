// Generated by CoffeeScript 1.10.0
joint.ui.SelectionView = Backbone.View.extend({
  options: {
    paper: void 0,
    graph: void 0
  },
  className: 'selection',
  events: {
    'mousedown .selection-box': 'startTranslatingSelection'
  },
  initialize: function(options) {
    this.options = options;
    _.bindAll(this, 'startSelecting', 'stopSelecting', 'adjustSelection');
    $(document.body).on('mouseup touchend', this.stopSelecting);
    $(document.body).on('mousemove touchmove', this.adjustSelection);
    this.options.paper.$el.append(this.$el);
  },
  startTranslatingSelection: function(evt) {
    var snappedClientCoords;
    this._action = 'translating';
    this.options.graph.trigger('batch:start');
    snappedClientCoords = this.options.paper.snapToGrid(g.point(evt.clientX, evt.clientY));
    this._snappedClientX = snappedClientCoords.x;
    this._snappedClientY = snappedClientCoords.y;
    this.trigger('selection-box:pointerdown', evt);
    evt.stopPropagation();
  },
  startSelecting: function(evt, x, y) {
    var paperElement, paperOffset, paperScrollLeft, paperScrollTop;
    if (evt.originalEvent.which === 2 || evt.originalEvent.which === 3) {
      return;
    }
    this.$el.removeClass('selected');
    this.$el.empty();
    this.model.reset([]);
    this._action = 'selecting';
    this._clientX = evt.clientX;
    this._clientY = evt.clientY;
    paperElement = evt.target.parentElement || evt.target.parentNode;
    paperOffset = $(paperElement).offset();
    paperScrollLeft = paperElement.scrollLeft;
    paperScrollTop = paperElement.scrollTop;
    this._offsetX = evt.offsetX === void 0 ? evt.clientX - paperOffset.left + window.pageXOffset + paperScrollLeft : evt.offsetX;
    this._offsetY = evt.offsetY === void 0 ? evt.clientY - paperOffset.top + window.pageYOffset + paperScrollTop : evt.offsetY;
    this.$el.css({
      width: 1,
      height: 1,
      left: this._offsetX,
      top: this._offsetY
    }).show();
  },
  adjustSelection: function(evt) {
    var dx, dy, height, left, paperScale, processedLinks, snappedClientCoords, snappedClientX, snappedClientY, top, width;
    dx = void 0;
    dy = void 0;
    switch (this._action) {
      case 'selecting':
        dx = evt.clientX - this._clientX;
        dy = evt.clientY - this._clientY;
        width = this.$el.width();
        height = this.$el.height();
        left = parseInt(this.$el.css('left'), 10);
        top = parseInt(this.$el.css('top'), 10);
        this.$el.css({
          left: dx < 0 ? this._offsetX + dx : left,
          top: dy < 0 ? this._offsetY + dy : top,
          width: Math.abs(dx),
          height: Math.abs(dy)
        });
        break;
      case 'translating':
        snappedClientCoords = this.options.paper.snapToGrid(g.point(evt.clientX, evt.clientY));
        snappedClientX = snappedClientCoords.x;
        snappedClientY = snappedClientCoords.y;
        dx = snappedClientX - this._snappedClientX;
        dy = snappedClientY - this._snappedClientY;
        processedLinks = {};
        this.model.each((function(element) {
          var connectedLinks;
          element.translate(dx, dy);
          connectedLinks = this.options.graph.getConnectedLinks(element);
          _.each(connectedLinks, function(link) {
            var newVertices, vertices;
            if (processedLinks[link.id]) {
              return;
            }
            vertices = link.get('vertices');
            if (vertices && vertices.length) {
              newVertices = [];
              _.each(vertices, function(vertex) {
                newVertices.push({
                  x: vertex.x + dx,
                  y: vertex.y + dy
                });
              });
              link.set('vertices', newVertices);
            }
            processedLinks[link.id] = true;
          });
        }), this);
        if (dx || dy) {
          paperScale = V(this.options.paper.viewport).scale();
          dx *= paperScale.sx;
          dy *= paperScale.sy;
          this.$('.selection-box').each(function() {
            var top;
            var left;
            left = parseFloat($(this).css('left'), 10);
            top = parseFloat($(this).css('top'), 10);
            $(this).css({
              left: left + dx,
              top: top + dy
            });
          });
          this._snappedClientX = snappedClientX;
          this._snappedClientY = snappedClientY;
        }
    }
  },
  stopSelecting: function() {
    var elementViews, height, localPoint, offset, width;
    switch (this._action) {
      case 'selecting':
        offset = this.$el.offset();
        width = this.$el.width();
        height = this.$el.height();
        localPoint = V(this.options.paper.svg).toLocalPoint(offset.left, offset.top);
        localPoint.x -= window.pageXOffset;
        localPoint.y -= window.pageYOffset;
        elementViews = this.options.paper.findViewsInArea(g.rect(localPoint.x, localPoint.y, width, height));
        if (elementViews.length) {
          _.each(elementViews, this.createSelectionBox, this);
          this.$el.addClass('selected');
        } else {
          this.$el.hide();
        }
        this.model.reset(_.pluck(elementViews, 'model'));
        break;
      case 'translating':
        this.options.graph.trigger('batch:stop');
        break;
      case 'cherry-picking':
        break;
      default:
        this.$el.hide().empty();
        this.model.reset([]);
        break;
    }
    delete this._action;
  },
  cancelSelection: function() {
    this.$('.selection-box').remove();
    this.$el.hide().removeClass('selected');
    this.model.reset([]);
  },
  destroySelectionBox: function(elementView) {
    this.$('[data-model="' + elementView.model.get('id') + '"]').remove();
    if (this.$('.selection-box').length === 0) {
      this.$el.hide().removeClass('selected');
    }
  },
  createSelectionBox: function(elementView) {
    var $selectionBox, viewBbox;
    viewBbox = elementView.getBBox();
    $selectionBox = $('<div/>', {
      'class': 'selection-box',
      'data-model': elementView.model.get('id')
    });
    $selectionBox.css({
      left: viewBbox.x,
      top: viewBbox.y,
      width: viewBbox.width,
      height: viewBbox.height
    });
    this.$el.append($selectionBox);
    this.$el.addClass('selected').show();
    this._action = 'cherry-picking';
  }
});

//# sourceMappingURL=selection.js.map
