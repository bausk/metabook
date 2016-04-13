// Generated by CoffeeScript 1.10.0
var metabook,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

metabook = {
  session: {},
  messages: {},
  ui: {},
  api: {
    file: {}
  },
  models: {},
  views: {},
  defaults: {},
  options: {}
};

metabook.api.get_template = function(success, error) {
  return $.ajax({
    url: metabook.api.template_endpoint + metabook.api.file.path,
    type: 'GET',
    success: success,
    error: error
  });
};

metabook.api.get_file = function(success, error) {
  return $.ajax({
    url: metabook.api.file.endpoint + metabook.api.file.path,
    type: 'GET',
    success: success,
    error: error
  });
};

metabook.api.get_ajax_data = function(data_uri, success, error) {
  return $.ajax({
    url: data_uri,
    type: 'GET',
    success: success,
    error: error
  });
};

metabook.api.is_good_form = function(json_data) {
  if (typeof json_data === 'object') {
    if ('metadata' in json_data) {
      if ('metabook' in json_data.metadata) {
        return true;
      }
    }
  }
  return false;
};

metabook.defaults = {
  cell: function(json_data) {
    if (metabook.api.is_good_form(json_data)) {
      return json_data.metadata.metabook.defaults.cell;
    }
    throw new Error();
  }
};

metabook.models.CellModel = (function(superClass) {
  extend(CellModel, superClass);

  function CellModel() {
    return CellModel.__super__.constructor.apply(this, arguments);
  }

  CellModel.prototype.initialize = function(attributes, data) {
    var cell_metadata;
    if (attributes.metadata != null) {
      cell_metadata = attributes.metadata;
    }
    if (data.generate_id) {
      _.merge(cell_metadata, data.cell_template.metadata);
      cell_metadata.metabook.id = joint.util.uuid();
    }
    _.merge(cell_metadata, data.extension.metadata);
    return this.set('metadata', cell_metadata);
  };

  CellModel.prototype.update_data = function(graph_cell) {
    var content, d, metadata;
    d = "\n";
    content = _.map(graph_cell.get('content').split(d), function(el) {
      return el + d;
    });
    if (_.last(content) === d) {
      content.pop();
    }
    this.set('source', content);
    metadata = _.clone(this.get('metadata'));
    metadata.metabook.inPorts = graph_cell.get('inPorts');
    metadata.metabook.outPorts = graph_cell.get('outPorts');
    metadata.metabook.position = graph_cell.get('position');
    return this.set('metadata', metadata);
  };

  return CellModel;

})(Backbone.Model);

metabook.models.LinkModel = (function(superClass) {
  extend(LinkModel, superClass);

  function LinkModel() {
    return LinkModel.__super__.constructor.apply(this, arguments);
  }

  LinkModel.prototype.initialize = function(attributes, data) {};

  LinkModel.prototype.update_data = function(graph_link) {};

  return LinkModel;

})(Backbone.Model);

metabook.models.CellCollection = (function(superClass) {
  extend(CellCollection, superClass);

  function CellCollection() {
    return CellCollection.__super__.constructor.apply(this, arguments);
  }

  CellCollection.prototype.model = metabook.models.CellModel;

  return CellCollection;

})(Backbone.Collection);

metabook.models.LinkCollection = (function(superClass) {
  extend(LinkCollection, superClass);

  function LinkCollection() {
    return LinkCollection.__super__.constructor.apply(this, arguments);
  }

  LinkCollection.prototype.model = metabook.models.LinkModel;

  return LinkCollection;

})(Backbone.Collection);

metabook.models.MetabookModel = (function(superClass) {
  extend(MetabookModel, superClass);

  function MetabookModel() {
    return MetabookModel.__super__.constructor.apply(this, arguments);
  }

  MetabookModel.prototype.initialize = function(attributes, data) {
    var cell_collection, cell_model, cell_template, code_cell, code_cells, curr_cell_id, elements, extension, generate_id, generic_cell, i, increment_x, increment_y, j, k, len, len1, len2, link, link_collection, link_model, links, metadata, prev_cell, prev_cell_id, ref, ref1, x, y;
    elements = [];
    links = [];
    extension = {};
    if (metabook.options["new"] === true && data.create_from === "native") {
      generate_id = true;
      cell_template = metabook.defaults.cell(data.json);
    } else {
      if (data.create_from !== "native") {
        generate_id = true;
        _.merge(data.json.metadata.metabook, data.template.metadata.metabook);
        cell_template = metabook.defaults.cell(data.template);
      } else {
        generate_id = false;
        cell_template = {};
      }
    }
    cell_collection = new metabook.models.CellCollection();
    increment_x = 500;
    increment_y = 20;
    x = 0;
    y = 0;
    ref = data.json.cells;
    for (i = 0, len = ref.length; i < len; i++) {
      generic_cell = ref[i];
      if (data.create_from !== "native") {
        extension = {
          metadata: {
            metabook: {
              position: {
                x: x,
                y: y
              }
            }
          }
        };
        x += increment_x;
        y += increment_y;
      }
      cell_model = new metabook.models.CellModel(generic_cell, {
        generate_id: generate_id,
        cell_template: cell_template,
        extension: extension
      });
      cell_collection.add(cell_model);
    }
    metadata = void 0;
    prev_cell = void 0;
    if (generate_id) {
      data.json.metadata.metabook.id = joint.util.uuid();
    }
    link_collection = new metabook.models.LinkCollection();
    if (data.create_from !== "native") {
      code_cells = cell_collection.filter({
        cell_type: "code"
      });
      for (j = 0, len1 = code_cells.length; j < len1; j++) {
        code_cell = code_cells[j];
        if (prev_cell) {
          prev_cell_id = prev_cell.get("metadata").metabook.id;
          curr_cell_id = code_cell.get("metadata").metabook.id;
          link_model = new metabook.models.LinkModel({
            source: {
              id: prev_cell_id,
              port: 'out:locals'
            },
            target: {
              id: curr_cell_id,
              port: 'in:locals'
            },
            id: joint.util.uuid()
          });
          link_collection.add(link_model);
        }
        prev_cell = code_cell;
      }
      metadata = data.template.metadata;
    } else {
      ref1 = data.json.metadata.metabook.links;
      for (k = 0, len2 = ref1.length; k < len2; k++) {
        link = ref1[k];
        link_model = new metabook.models.LinkModel(link);
        link_collection.add(link_model);
      }
      metadata = data.json.metadata;
      if (generate_id === true) {
        metadata.metabook.id = joint.util.uuid();
      }
    }
    metadata.metabook.links = link_collection;
    this.set('cells', cell_collection);
    this.set('nbformat', data.json.nbformat);
    this.set('nbformat_minor', data.json.nbformat_minor);
    this.set('metadata', metadata);
    if (metadata.metabook.id) {
      return this.set('id', metadata.metabook.id);
    }
  };

  MetabookModel.prototype.actions = {
    'notebook.save': function(ev) {
      var call_type, data;
      data = JSON.stringify(this.attributes);
      call_type = metabook.options["new"] ? 'POST' : 'PUT';
      return $.ajax({
        url: metabook.api.file.endpoint + metabook.api.file.path,
        type: call_type,
        data: data,
        success: _.bind((function(json_data, status, xhr) {
          alert('Succesfully uploaded data.');
          if (json_data.new_id) {
            this.set('id', json_data.new_id);
            history.replaceState(null, null, "/" + json_data.new_path);
            metabook.api.file.path = json_data.new_path;
            metabook.options["new"] = false;
            return metabook.api.file.name = json_data.new_name;
          }
        }), this),
        error: error_graph
      });
    }
  };

  return MetabookModel;

})(Backbone.Model);

metabook.views.MenuView = (function(superClass) {
  extend(MenuView, superClass);

  function MenuView() {
    return MenuView.__super__.constructor.apply(this, arguments);
  }

  MenuView.prototype.events = {
    "click [data-action]": function(ev) {
      return _.bind(this.model.actions[$(ev.target).data('action')], this.model)(ev);
    }
  };

  return MenuView;

})(Backbone.View);

//# sourceMappingURL=metabook.js.map
