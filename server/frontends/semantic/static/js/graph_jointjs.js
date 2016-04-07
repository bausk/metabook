// Generated by CoffeeScript 1.10.0
var custom_shapes, graphics, init_jointjs, jointjs_attach_events,
  slice = [].slice;

graphics = {};

custom_shapes = [];

init_jointjs = function(graph_template, graph_json) {
  var cell_collection, cell_model, code_cells, elements, graph, i, len, link, links, node, paper_holder, prev_node, pycell, setting_increment_x, setting_increment_y, setting_start_x, setting_start_y;
  paper_holder = $(Settings.id.graph_container);
  Obj.graph = new joint.dia.Graph();
  Obj.mainpaper = new GraphPaper({
    el: $(Settings.id.paper),
    width: paper_holder.width(),
    height: paper_holder.height(),
    model: Obj.graph,
    gridSize: 1,
    defaultLink: new joint.shapes.html.Link
  });
  graph = Obj.graph;
  setting_start_x = 30;
  setting_start_y = 30;
  setting_increment_x = 500;
  setting_increment_y = 100;
  elements = [];
  links = [];
  prev_node = void 0;
  code_cells = _.filter(graph_json.cells, function(o) {
    return o['cell_type'] === "code";
  });
  cell_collection = new metabook.models.CellCollection();
  for (i = 0, len = code_cells.length; i < len; i++) {
    pycell = code_cells[i];
    cell_model = new metabook.models.CellModel(pycell, pycell);
    cell_collection.add(cell_model);
    node = new joint.shapes.html.Node({
      position: {
        x: setting_start_x,
        y: setting_start_y
      },
      content: pycell.source.join(""),
      footing_content: "ipynb cell [" + pycell.execution_count + "]",
      node_markup: {
        node_viewer: '<div class="node_viewer python" data-metabook="true"></div>',
        node_editor: '<span class="ui form node_editor"><textarea class="node_coupled"></textarea></span>'
      },
      dimensions: {
        'min-height': 100,
        'max-height': 200,
        'min-width': 250,
        'max-width': 500
      },
      inPorts: ['in:locals'],
      outPorts: ['out:locals']
    }, {
      cell_model: cell_model
    });
    elements.push(node);
    if (prev_node) {
      link = new joint.shapes.html.Link({
        source: {
          id: prev_node.id,
          port: 'out:locals'
        },
        target: {
          id: node.id,
          port: 'in:locals'
        }
      });
      links.push(link);
    }
    prev_node = node;
    setting_start_x += setting_increment_x;
    setting_start_y += setting_increment_y;
  }
  graph.addCells(slice.call(elements).concat(slice.call(links)));
  return cell_collection;
};

jointjs_attach_events = function(paper, graph) {
  var selection, selectionView;
  selection = new Backbone.Collection;
  selectionView = new joint.ui.SelectionView({
    paper: paper,
    graph: graph,
    model: selection
  });
  return paper.on('blank:pointerdown', selectionView.startSelecting);
};

//# sourceMappingURL=graph_jointjs.js.map
