/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports) {

	// Generated by CoffeeScript 1.10.0
	var a, error_graph, init_graph;
	
	Settings.id = {
	  messages: "#messages",
	  coords: "#coords",
	  graph_container: "#paper_holder",
	  paper: "#myholder",
	  svg: "#v-2"
	};
	
	a = 1;
	
	$(document).ready(function() {
	  var global_state, session, uivent;
	  uivent = new metabook.ui.Vent();
	  uivent.register({
	    'ui': metabook.ui
	  });
	  global_state = new metabook.models.ApplicationState();
	  global_state.set({
	    graph_ready: false
	  });
	  $("#id2").dimmer({
	    closable: false
	  }).dimmer('show');
	  session = new metabook.connect.Session(metabook.uri.sessions_endpoint);
	  session.connect_metabook(metabook.uri.file.path, init_graph);
	  return metabook.data.get_xhr(metabook.uri.file.endpoint + metabook.uri.file.path).done(function(file_json) {
	    return init_graph(file_json);
	  }).fail(error_graph);
	});
	
	init_graph = function(json_graph) {
	  var menuview, notebook, paper;
	  notebook = new metabook.models.MetabookModel({}, {
	    json_graph: json_graph
	  });
	  paper = init_jointjs(notebook);
	  notebook.session = new metabook.connect.Session(metabook.uri.sessions_endpoint, notebook.id);
	  $("#id2").dimmer('hide');
	  $("#bottom_sidebar").sidebar({
	    context: $('#id2')
	  });
	  $("#bottom_sidebar").sidebar('setting', 'transition', 'overlay');
	  $("#bottom_sidebar").sidebar('setting', 'dimPage', false);
	  $("#bottom_sidebar").sidebar('attach events', '#uiMenuToggle');
	  $("#bottom_sidebar").sidebar('setting', 'closable', false);
	  uivent.register({
	    'session': notebook.session,
	    'model': notebook,
	    'graph': paper.model
	  });
	  jointjs_attach_events(paper, paper.model);
	  return menuview = new metabook.views.MenuView({
	    el: $("#metabook_top_menu"),
	    model: notebook
	  });
	};
	
	error_graph = function(e) {
	  $("#id2").dimmer('hide');
	  return alert("Connection error. Check if your backend is running.");
	};
	
	//# sourceMappingURL=graph.js.map


/***/ }
/******/ ]);
//# sourceMappingURL=bundle.js.map