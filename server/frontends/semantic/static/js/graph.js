// Generated by CoffeeScript 1.10.0
var error_graph, init_graph;

Settings.id = {
  messages: "#messages",
  coords: "#coords",
  graph_container: "#paper_holder",
  paper: "#myholder",
  svg: "#v-2"
};

$(document).ready(function() {
  $("#id2").dimmer({
    closable: false
  }).dimmer('show');
  return metabook.data.get_xhr(metabook.uri.file.endpoint + metabook.uri.file.path).done(function(file_json) {
    return init_graph(file_json);
  }).fail(error_graph);
});

init_graph = function(json_graph) {
  var menuview, notebook, paper, uivent;
  notebook = new metabook.models.MetabookModel({}, {
    json_graph: json_graph
  });
  paper = init_jointjs(notebook);
  notebook.session = new metabook.connect.Session(metabook.uri.sessions_endpoint);
  $("#id2").dimmer('hide');
  $("#uiLeftSidebar").sidebar({
    context: $('#id2')
  });
  $("#uiLeftSidebar").sidebar('setting', 'transition', 'overlay');
  $("#uiLeftSidebar").sidebar('setting', 'dimPage', false);
  $("#uiLeftSidebar").sidebar('attach events', '#uiMenuToggle');
  $("#uiLeftSidebar").sidebar('setting', 'closable', false);
  ContextMenu.init(Settings);
  uivent = new metabook.ui.Vent();
  uivent.register({
    'session': notebook.session,
    'model': notebook
  });

  /*
  $("[data-action]").on('click', (e) ->
      action = e.target.dataset.action
      actions = Settings.ui.actions
      if `action in actions`
          ContextMenu.active_menu_off()
          actions[action].apply(paper, arguments)
  )
   */
  jointjs_attach_events(paper, paper.model);
  return menuview = new metabook.views.MenuView({
    el: $(".menu"),
    model: notebook
  });
};

error_graph = function(e) {
  $("#id2").dimmer('hide');
  return alert("Connection error. Check if your backend is running.");
};

//# sourceMappingURL=graph.js.map
