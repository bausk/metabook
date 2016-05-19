// Generated by CoffeeScript 1.10.0
var custom_shapes, graphics, init_jointjs, jointjs_attach_events,
  slice = [].slice;

graphics = {};

custom_shapes = [];

init_jointjs = function(metabook_model) {
  var cells, elems_list, graph, links, links_list, mainpaper, paper_holder;
  paper_holder = $(Settings.id.graph_container);
  graph = new metabook.MetaGraph({}, metabook_model);
  mainpaper = new GraphPaper({
    el: $(Settings.id.paper),
    width: paper_holder.width(),
    height: paper_holder.height(),
    model: graph,
    gridSize: 1,
    defaultLink: new joint.shapes.html.Link
  });
  elems_list = [];
  links_list = [];
  cells = metabook_model.get("cells");
  links = metabook_model.get("links");
  cells.each(function(cell_model) {
    var content, id, node, position, source;
    source = cell_model.get('source');
    id = cell_model.id;
    if (typeof source !== "string") {
      content = source.join("");
    } else {
      content = source;
    }
    position = cell_model.get('position');
    node = new joint.shapes.html.Node({
      id: id,
      position: {
        x: position.x,
        y: position.y
      },
      content: content,
      footing_content: "[ipynb cell]",
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
      inPorts: cell_model.get('inPorts'),
      outPorts: cell_model.get('outPorts')
    }, {
      cell_model: cell_model
    });
    return elems_list.push(node);
  });
  links.each(function(link_model) {
    var link;
    link = new joint.shapes.html.Link({
      source: link_model.get('source'),
      target: link_model.get('target'),
      id: link_model.get('id')
    });
    return links_list.push(link);
  });
  graph.addCells(slice.call(elems_list).concat(slice.call(links_list)));
  return mainpaper;
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
