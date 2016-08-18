// Generated by CoffeeScript 1.10.0
var ApplicationState, CellCollection, CellModel, DetailsView, LinkCollection, LinkModel, MenuView, MetabookModel, imports,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

imports = {
  data: require("./data"),
  util: require("./util")
};

CellModel = (function(superClass) {
  extend(CellModel, superClass);

  function CellModel() {
    return CellModel.__super__.constructor.apply(this, arguments);
  }

  CellModel.prototype.initialize = function(attributes, data) {};

  CellModel.prototype.update_data = function(graph_cell) {
    var content, d;
    d = "\n";
    content = _.map(graph_cell.get('content').split(d), function(el) {
      return el + d;
    });
    if (_.last(content) === d) {
      content.pop();
    }
    this.set('source', content);
    this.set('inPorts', graph_cell.get('inPorts'));
    this.set('outPorts', graph_cell.get('outPorts'));
    return this.set('position', graph_cell.get('position'));
  };

  return CellModel;

})(Backbone.Model);

LinkModel = (function(superClass) {
  extend(LinkModel, superClass);

  function LinkModel() {
    return LinkModel.__super__.constructor.apply(this, arguments);
  }

  LinkModel.prototype.initialize = function(attributes, data) {};

  LinkModel.prototype.update_data = function(graph_link) {};

  return LinkModel;

})(Backbone.Model);

ApplicationState = (function(superClass) {
  extend(ApplicationState, superClass);

  function ApplicationState() {
    return ApplicationState.__super__.constructor.apply(this, arguments);
  }

  ApplicationState.prototype.initialize = function(attributes, data) {
    return this.on('change:graph_ready', this.graph_ready, this);
  };

  ApplicationState.prototype.graph_ready = function() {};

  return ApplicationState;

})(Backbone.Model);

CellCollection = (function(superClass) {
  extend(CellCollection, superClass);

  function CellCollection() {
    return CellCollection.__super__.constructor.apply(this, arguments);
  }

  CellCollection.prototype.model = CellModel;

  return CellCollection;

})(Backbone.Collection);

LinkCollection = (function(superClass) {
  extend(LinkCollection, superClass);

  function LinkCollection() {
    return LinkCollection.__super__.constructor.apply(this, arguments);
  }

  LinkCollection.prototype.model = LinkModel;

  return LinkCollection;

})(Backbone.Collection);

MetabookModel = (function(superClass) {
  extend(MetabookModel, superClass);

  function MetabookModel() {
    return MetabookModel.__super__.constructor.apply(this, arguments);
  }

  MetabookModel.prototype.initialize = function(attributes, arg) {
    var cell, cell_collection, cell_model, i, j, json_graph, len, len1, link_collection, link_model, ref, ref1;
    json_graph = arg.json_graph;
    cell_collection = new CellCollection();
    ref = json_graph.cells;
    for (i = 0, len = ref.length; i < len; i++) {
      cell = ref[i];
      cell_model = new CellModel(cell);
      cell_collection.add(cell_model);
    }
    this.set('cells', cell_collection);
    link_collection = new LinkCollection();
    ref1 = json_graph.links;
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      link_model = ref1[j];
      link_collection.add(link_model);
    }
    this.set('links', link_collection);
    this.set('tabs', json_graph.tabs);
    this.set('results', json_graph.results);
    return this.set('id', json_graph.id);
  };

  MetabookModel.prototype.custom_events = {
    'save': function(caller, ev) {
      var call_type, data;
      data = JSON.stringify(this.attributes);
      call_type = imports.util.get_parameter('new') ? 'POST' : 'PUT';
      return $.ajax({
        url: config.file.endpoint + config.file.path,
        type: call_type,
        data: data,
        success: _.bind((function(json_data, status, xhr) {
          console.log('Succesfully uploaded data');
          if (json_data.new_path) {
            history.replaceState(null, null, "/" + json_data.new_path);
            config.file.path = json_data.new_path;
            return config.file.name = json_data.new_name;
          }
        }), this),
        error: error_graph
      });
    },
    'solve': function(caller, ev) {
      return this.session.solve_all(this, ev);
    }
  };

  MetabookModel.prototype.data = {
    get_cells: _.partial(imports.data.get_cells, MetabookModel),
    get_links: _.partial(imports.data.get_links, MetabookModel)
  };

  return MetabookModel;

})(Backbone.Model);

MenuView = (function(superClass) {
  extend(MenuView, superClass);

  function MenuView() {
    return MenuView.__super__.constructor.apply(this, arguments);
  }

  MenuView.prototype.events = {
    "click [data-action]": function(ev) {
      var custom_event;
      custom_event = ev.target.dataset.action;
      Backbone.trigger(custom_event, this.model, ev);
      return console.log("MenuView event triggered");
    }
  };

  return MenuView;

})(Backbone.View);

DetailsView = (function(superClass) {
  extend(DetailsView, superClass);

  function DetailsView() {
    this.zombieguard = bind(this.zombieguard, this);
    this.remove = bind(this.remove, this);
    this.abort = bind(this.abort, this);
    this.confirm = bind(this.confirm, this);
    this.render = bind(this.render, this);
    this.initialize = bind(this.initialize, this);
    return DetailsView.__super__.constructor.apply(this, arguments);
  }

  DetailsView.prototype.template = "<div class=\"ui modal\" style=\"top:100px\">\n<div class=\"header\">\n  Node Properties: FACB345\n</div>\n<div class=\"content\">\n  <div class=\"ui form properties\">\n    <h4 class=\"ui dividing header\">Type chain: </h4>\n    <h4 class=\"ui dividing header\">Tags: </h4>\n    <div class=\"ui three column centered divided grid\">\n        <div class=\"row\">\n            <div class=\"ui four wide column\">\n                          <label>Inputs:</label>\n            </div>\n            <div class=\"ui eight wide column\">\n                          <label>Code:</label><br/>\n                <textarea class=\"properties\">blehbleh bleh</textarea>\n            </div>\n            <div class=\"ui four wide column\">\n                          <label>Outputs:</label>\n            </div>\n        </div>\n\n    </div>\n  </div>\n</div>\n<div class=\"actions\">\n  <div class=\"ui button cancel\">Cancel</div>\n  <div class=\"ui green button ok\" style=\"min-width:200px\">OK</div>\n</div>\n</div>";

  DetailsView.prototype.events = {
    'click .ok': "confirm",
    'click .cancel': "abort"
  };

  DetailsView.prototype.initialize = function(arg) {
    var template;
    template = arg.template;
    return this.render();
  };

  DetailsView.prototype.render = function() {
    this.$el.html(this.template);
    this.$modal = this.$el.find('.ui.modal');
    this.$modal.modal({
      detachable: false,
      closable: false
    });
    this.$modal.modal('show');
    this.$modal.find('textarea.properties').val(this.model.get('content'));
    this.delegateEvents();
    return $('.zombieguard').on("click", this.zombieguard);
  };

  DetailsView.prototype.confirm = function() {
    return this.remove();
  };

  DetailsView.prototype.abort = function() {
    return this.remove();
  };

  DetailsView.prototype.remove = function() {
    this.stopListening();
    this.undelegateEvents();
    this.off();
    this.model.off(null, null, this);
    this.$modal.modal('hide');
    return this.$modal.remove();
  };

  DetailsView.prototype.zombieguard = function() {
    return alert(this.classname);
  };

  return DetailsView;

})(Backbone.View);

module.exports = {
  views: {
    DetailsView: DetailsView,
    MenuView: MenuView
  },
  models: {
    CellModel: CellModel,
    LinkModel: LinkModel,
    LinkCollection: LinkCollection,
    CellCollection: CellCollection,
    ApplicationState: ApplicationState,
    MetabookModel: MetabookModel
  }
};

//# sourceMappingURL=objects.js.map