// Generated by CoffeeScript 1.10.0
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

metabook.MetaGraph = (function(superClass) {
  extend(MetaGraph, superClass);

  function MetaGraph() {
    return MetaGraph.__super__.constructor.apply(this, arguments);
  }

  MetaGraph.prototype.initialize = function(attrs, data) {
    this.metabook = data;
    return this.constructor.__super__.initialize.apply(this, arguments);
  };

  MetaGraph.prototype.custom_events = {
    "node": metabook.ui.Vent.passover,
    "newnode": function(ev) {
      return console.log("<graph:newnode>");
    }
  };

  return MetaGraph;

})(joint.dia.Graph);

joint.shapes.html.Node = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {
  markup: '<g class="rotatable"><g class="scalable"><rect class="body"/></g><text class="label"/><g class="inPorts"/><g class="outPorts"/></g>',
  portMarkup: '<g class="port port<%= id %>"><circle class="port-body"/></g>',
  defaults: joint.util.deepSupplement({
    type: 'html.Node',
    size: {
      width: 350,
      height: 100
    },
    inPorts: ['In[0]'],
    outPorts: ['Out[0]'],
    attrs: {
      rect: {
        stroke: 'none',
        fill: 'transparent',
        'stroke-opacity': 0,
        'fill-opacity': 0
      },
      '.': {
        magnet: false
      },
      '.body': {
        width: 150,
        height: 150,
        stroke: '#000000'
      },
      '.port-body': {
        r: 10,
        magnet: true,
        stroke: '#000000'
      },
      text: {
        'pointer-events': 'none'
      },
      '.label': {
        text: 'Model',
        'ref-x': .5,
        'ref-y': 10,
        ref: '.body',
        'text-anchor': 'middle',
        fill: '#000000'
      },
      '.inPorts .port-label': {
        x: -15,
        dy: 4,
        'text-anchor': 'end',
        fill: '#000000'
      },
      '.outPorts .port-label': {
        x: 15,
        dy: 4,
        fill: '#000000'
      },
      '.inPorts circle': {
        fill: '#666666',
        'stroke-opacity': 0
      },
      '.outPorts circle': {
        fill: '#999999',
        'stroke-opacity': 0
      },
      '.inPorts .port-body': {
        fill: '#333333'
      },
      '.outPorts .port-body': {
        fill: '#666666'
      }
    },
    head_content: 'Cell: ID',
    content: 'Click to edit code',
    footing_content: 'Version A4D3E453',
    node_markup: {
      head: '<span class="content_head">Code Cell: FGFDG3456FGDFE</span>',
      node_viewer: '<div class="node_viewer"></div>',
      node_editor: '<span class="ui form node_editor"><textarea class="node_coupled"></textarea></span>',
      footing: '<span class="ui small label content_footing" style="font-family: monospace">Python file</span>'
    }
  }, joint.shapes.basic.Generic.prototype.defaults),
  initialize: function(attrs, data) {
    this.cell_model = data.cell_model;
    this.on('change', _.bind((function() {
      console.log('<change:content>');
      return this.cell_model.update_data(this);
    }), this));
    this.on('change:position', _.bind((function() {
      return this.cell_model.update_data(this);
    }), this));
    this.updatePortsAttrs();
    this.on('change:inPorts change:outPorts', this.updatePortsAttrs, this);
    return this.constructor.__super__.constructor.__super__.initialize.apply(this, arguments);
  },
  getPortAttrs: function(portName, index, total, selector, type) {
    var attrs, portBodySelector, portClass, portLabelSelector, portSelector;
    attrs = {};
    portClass = 'port' + index;
    portSelector = selector + '>.' + portClass;
    portLabelSelector = portSelector + '>.port-label';
    portBodySelector = portSelector + '>.port-body';
    attrs[portLabelSelector] = {
      text: portName
    };
    attrs[portBodySelector] = {
      port: {
        id: portName || _.uniqueId(type),
        type: type
      }
    };
    attrs[portSelector] = {
      ref: '.body',
      'ref-y': (39 / 38 + 0.5 + index) / (39 / 38 + total)
    };
    if (selector === '.outPorts') {
      attrs[portSelector]['ref-dx'] = 0;
    }
    return attrs;
  },
  custom_events: {
    properties: function() {
      return console.log("properties");
    }
  }
}));

joint.shapes.html.NodeView = joint.dia.ElementView.extend(_.extend({}, joint.shapes.basic.PortsViewInterface, {
  template: ['<div style="position:absolute" class="node_container selection-box">', '<table class="ui very compact celled table node_table">', '<thead><tr data-metabook="node-head"><th colspan="3" class="node_head" data-content="Blergh"><%= head %></th></tr></thead>', '<tbody><tr class="content_row"><td class="node_empty"></td>', '<td class="node_content" rowspan="1"><%= node_viewer %><%= node_editor %></td>', '<td class="node_empty"></td></tr></tbody>', '<tfoot><tr><th colspan="3" class="node_footing"><%= footing %></th></tr></tfoot>', '</table>', '</div>'].join(''),
  content: {},
  initialize: function(attributes, data) {
    joint.dia.ElementView.prototype.initialize.apply(this, arguments);
    this.isdraggable = false;
    this.isedited = false;
    this.isrendered = false;
    this.dragpoint = {
      x: 0,
      y: 0,
      paper_x: 0,
      paper_y: 0,
      client_x: 0,
      client_y: 0,
      offset_x: 0,
      offset_y: 0
    };
    this.$box = $(_.template(this.template)(this.model.get('node_markup')));
    this.$box.find('.node_editor').addClass('invisible');
    this.$box.find('.node_viewer').css(this.model.get('dimensions'));
    this.$box.find('th.node_head').on('mousedown', _.bind((function(evt) {
      var point, point2;
      evt = evt.originalEvent;
      if (evt.which !== 1) {
        return;
      }
      this.dragpoint.x = evt.pageX;
      this.dragpoint.y = evt.pageY;
      point = this.paper.origin;
      this.dragpoint.offset_x = point.x * this.paper.scale;
      this.dragpoint.offset_y = point.y * this.paper.scale;
      point2 = this.paper.offsetToLocalPoint(this.dragpoint.x, this.dragpoint.y);
      this.dragpoint.paper_x = point2.x;
      this.dragpoint.paper_y = point2.y;
      this.dragpoint.client_x = this.model.get('position').x;
      this.dragpoint.client_y = this.model.get('position').y;
      return this.isdraggable = true;
    }), this));
    this.$box.find('th.node_head').popup();
    $(window).on('mousemove', _.bind((function(evt) {
      var point;
      if (this.isdraggable) {
        if (evt.buttons !== 1) {
          this.isdraggable = false;
          return;
        }
        evt = evt.originalEvent;
        point = this.paper.offsetToLocalPoint(evt.pageX, evt.pageY);
        return this.model.set('position', {
          x: this.dragpoint.client_x - this.dragpoint.paper_x + point.x,
          y: this.dragpoint.client_y - this.dragpoint.paper_y + point.y
        });
      }
    }), this));
    $(window).on('mouseup', _.bind((function(e) {
      return this.isdraggable = false;
    }), this));
    this.$box.find('.btn_close').on('click', _.bind(this.model.remove, this.model));
    this.$box.find('[data-action]').on('click', this.dispatch(this));
    this.model.on('change', this.updateBox, this);
    this.model.on('remove', this.removeBox, this);
    custom_shapes.push(this);
    this.$box.find('.node_content').on('click', _.bind(this.startEditInPlace, this));
    return this.$box.find('.node_head').on('dblclick', _.bind(this.showDetails, this));
  },
  dispatch: function(self) {
    return function(evt) {
      var custom_event;
      custom_event = this.dataset.action;
      Backbone.trigger(custom_event, self, evt);
      return console.log("<" + custom_event + ">");
    };
  },
  render: function() {
    this.processPorts();
    joint.dia.ElementView.prototype.render.apply(this, arguments);
    if (this.isrendered === false) {
      this.paper.$el.prepend(this.$box);
    }
    this.updateBox();
    this.isrendered = true;
    Backbone.trigger("ui:add", this);
    console.log("<ui:add>");
    return this;
  },

  /*    update: ->
  
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
   */
  processPorts: function() {
    var pairs, rows;
    this.$box.find('tbody tr').not(':first').remove();
    pairs = _.zip(this.model.get('inPorts'), this.model.get('outPorts'));
    rows = 1;
    _.each(pairs, _.bind(function(pair) {
      var ref, ref1;
      this.$box.find('tbody tr:last td').first().replaceWith("<td class='node_in'>" + ((ref = pair[0]) != null ? ref : "") + "</td>");
      $("<td class='ui node_out' data-content='fssdfsdfsdfs'>" + ((ref1 = pair[1]) != null ? ref1 : "") + "</td>").replaceAll(this.$box.find('tbody tr:last td').last()).popup({
        position: 'right center'
      });
      this.$box.find('tbody tr:last').after('<tr><td class="node_empty"></td><td class="node_empty"></td></tr>');
      return rows++;
    }, this));
    this.$box.find('.node_content').attr('rowspan', rows);
    return this.$box.find('.node_empty').on('click', _.bind((function(evt) {
      var ports, portsname;
      if ($(evt.target).is(':last-child')) {
        portsname = 'outPorts';
      } else {
        portsname = 'inPorts';
      }
      ports = this.model.get(portsname);
      ports.push('newport' + Math.random().toPrecision(2));
      this.model.set(portsname, ports);
      this.model.updatePortsAttrs();
      return this.render();
    }), this));
  },
  showDetails: function(ev) {
    var details_modal;
    ev.stopPropagation();
    return details_modal = new metabook.views.DetailsView({
      el: $("#modal_menu"),
      model: this.model,
      template: $("#modal_menu_template")
    });
  },
  startEditInPlace: function() {
    this.$box.find('.node_viewer').addClass('invisible');
    this.$box.find('.node_coupled').css('width', parseInt(this.$box.find('.node_viewer').css('width')) + 6);
    this.$box.find('.node_coupled').css('height', parseInt(this.$box.find('.node_viewer').css('height')) + 6);
    this.$box.find('.node_editor').removeClass('invisible').find('.node_coupled').focus();
    this.isedited = true;
    this.$box.find('.node_editor').on('mousemove', function(evt) {
      return evt.stopPropagation();
    });
    this.$box.find('.node_coupled').on('keydown', _.bind((function(evt) {
      if (evt.keyCode === 27) {
        this.isedited = false;
        this.$box.find('.node_coupled').blur();
      }
      if (evt.keyCode === 13 && evt.ctrlKey === true) {
        return this.$box.find('.node_coupled').blur();
      }
    }), this));
    this.$box.find('.node_coupled').on('keyup', _.bind((function(evt) {
      var newcontent, textarea, view;
      textarea = this.$box.find('.node_coupled');
      view = this.$box.find('.node_viewer');
      newcontent = textarea.val();
      view.html(newcontent);
      textarea.css('width', parseInt(view.css('width')) + 6);
      return textarea.css('height', parseInt(view.css('height')) + 6);
    }), this));
    this.$box.find('.node_coupled').on('mousewheel', _.bind((function(evt) {
      return evt.stopPropagation();
    }), this));
    return this.$box.find('.node_coupled').on('blur', _.bind((function(evt) {
      var newcontent, textarea, view;
      textarea = this.$box.find('.node_coupled');
      view = this.$box.find('.node_viewer');
      newcontent = textarea.val();
      if (this.isedited === true) {
        this.model.set('content', newcontent);
        view.html(newcontent);
      }
      this.isedited = false;
      this.$box.find('.node_editor').addClass('invisible');
      this.$box.find('.node_viewer').removeClass('invisible');
      return this.updateBox();
    }), this));
  },
  updateBox: function() {
    var bbox, height0, height1, height2, heightall, ref, scale, x, y;
    bbox = this.model.getBBox();
    ref = this.paper.getRealCoords(bbox.x, bbox.y), x = ref.x, y = ref.y;
    bbox.x = x;
    bbox.y = y;
    scale = this.paper.current_scale;
    this.$box.find('label').text(this.model.get('label'));
    this.$box.find('span').text(this.model.get('select'));
    this.$box.find('.node_viewer').html(this.model.get('content'));
    if (this.isedited === false) {
      this.$box.find('.node_coupled').val(this.model.get('content'));
    }
    this.$box.find('.content_footing').html(this.model.get('footing_content'));
    this.$box.css('transform-origin', 'left top');
    this.$box.css({
      left: bbox.x,
      top: bbox.y,
      transform: 'rotate(' + (this.model.get('angle') || 0) + 'deg) scale(' + scale + ')'
    });
    height0 = parseInt(this.$box.find('thead').css('height'));
    height1 = parseInt(this.$box.find('tbody').css('height'));
    height2 = parseInt(this.$box.find('tbody tr').last().css('height'));
    heightall = height0 + height1 - height2;
    this.model.set('size', {
      width: parseInt(this.$box.css('width')),
      height: heightall
    });
    return hljs.highlightBlock(this.$box.find('.node_viewer')[0]);
  },
  removeBox: function(evt) {
    return this.$box.remove();
  }
}));

joint.shapes.html.Link = (function(superClass) {
  extend(Link, superClass);

  function Link() {
    return Link.__super__.constructor.apply(this, arguments);
  }

  Link.prototype.defaults = {
    smooth: true,
    type: 'html.Link',
    attrs: {
      '.connection': {
        'stroke-width': 4,
        stroke: '#a0a0a9'
      }
    }
  };

  return Link;

})(joint.dia.Link);


/*
joint.shapes.html.Link = joint.dia.Link.extend({

    defaults: {
        smooth: true
        type: 'html.Link',
        attrs: { '.connection': { 'stroke-width': 5, stroke: '#a0a0a9' } }
    }
})
 */

//# sourceMappingURL=node.js.map
