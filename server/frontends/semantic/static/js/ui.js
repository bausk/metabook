// Generated by CoffeeScript 1.10.0
(function() {
  var ContextMenu, ContextMenuView, GlobalGUI, Settings, Vent, bind_context_menus, custom_events, settings,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Settings = require("./settings");

  settings = {
    active_menu_class: "context-menu--active",
    selector: "#context-menu",
    context_bindings: {
      ".element": "#context-menu",
      "svg": "#context-menu2"
    },
    templates: {
      node: "<a href=\"#\" class=\"item\" data-action=\"graph:node:properties\"><i class=\"fa fa-tasks\"></i> Properties <div class=\"ui small inverted label\">Ctrl+Enter</div></a>\n<a href=\"#\" class=\"item\" data-action=\"session:run\"><i class=\"fa fa-play\"></i> Run Node <div class=\"ui small inverted label\">Ctrl+E</div></a>\n<a href=\"#\" class=\"item\" data-action=\"graph:node:update\"><i class=\"fa fa-exchange\"></i> Sync to Server <div class=\"ui small inverted label\">Ctrl+D</div></a>\n<a href=\"#\" class=\"item\" data-action=\"graph:node:expand\"><i class=\"fa fa-expand\"></i> Expand & Edit <div class=\"ui small inverted label\">Ctrl+D</div></a>\n<a href=\"#\" class=\"item\" data-action=\"graph:node:duplicate\"><i class=\"fa fa-copy\"></i> Duplicate <div class=\"ui small inverted label\">Ctrl+D</div></a>\n<a href=\"#\" class=\"item\" data-action=\"graph:node:similar\"><i class=\"fa fa-plus\"></i> Select Similar <div class=\"ui small inverted label\">Ctrl+D</div></a>\n<a href=\"#\" class=\"item\" data-action=\"graph:node:delete\"><i class=\"fa fa-times\"></i> Delete <div class=\"ui small inverted label\">Ctrl+D</div></a>",
      blank: "<a href=\"#\" class=\"item\" data-action=\"graph:newnode\"><i class=\"fa fa-eye\"></i> New node <div class=\"ui small inverted label\">Ctrl+D</div></a>\n<a href=\"#\" class=\"item\" data-action=\"model:solve\"><i class=\"fa fa-edit\"></i> Run <div class=\"ui small inverted label\">Ctrl+E</div></a>\n<a href=\"#\" class=\"item\" data-action=\"graph:node:delete\"><i class=\"fa fa-times\"></i> Delete <div class=\"ui small inverted label\">Ctrl+D</div></a>"
    }
  };

  bind_context_menus = function() {
    var menu_id, ref, results, selector;
    ref = settings.context_bindings;
    results = [];
    for (selector in ref) {
      menu_id = ref[selector];
      results.push(this.context_listener.apply(this, [selector, menu_id]));
    }
    return results;
  };

  custom_events = {
    'add': function(cell) {
      return cell.$box.on('contextmenu', _.partialRight(function(e, cell) {
        var menu;
        e.preventDefault();
        return menu = new ContextMenuView(cell.model, {
          cell: cell,
          event: e,
          "class": settings.active_menu_class,
          selector: settings.selector,
          template: settings.templates.node
        });
      }, cell));
    },
    'blankmenu': function(paper, e) {
      var menu;
      e.preventDefault();
      return menu = new ContextMenuView(paper.model, {
        event: e,
        "class": settings.active_menu_class,
        selector: settings.selector,
        template: settings.templates.blank
      });
    }
  };

  GlobalGUI = (function(superClass) {
    extend(GlobalGUI, superClass);

    function GlobalGUI() {
      return GlobalGUI.__super__.constructor.apply(this, arguments);
    }

    GlobalGUI.prototype.initialize = function() {
      this.listenTo(Backbone, 'graph:notready', this.dim);
      return this.listenTo(Backbone, 'graph:ready', this.undim);
    };

    GlobalGUI.prototype.dim = function() {
      return $("#id2").dimmer({
        closable: false
      }).dimmer('show');
    };

    GlobalGUI.prototype.undim = function() {
      return $("#id2").dimmer('hide');
    };

    return GlobalGUI;

  })(Backbone.View);

  ContextMenuView = (function(superClass) {
    extend(ContextMenuView, superClass);

    function ContextMenuView() {
      this.getPosition = bind(this.getPosition, this);
      this.position_active_menu = bind(this.position_active_menu, this);
      this.hide = bind(this.hide, this);
      return ContextMenuView.__super__.constructor.apply(this, arguments);
    }

    ContextMenuView.prototype.initialize = function(model, settings) {
      this.active_menu_class = settings["class"];
      this.template = settings.template;
      this.el = $(settings.selector);
      this.event = settings.event;
      this.model = model;
      this.cell = settings.cell;
      Backbone.View.prototype.initialize.apply(this, arguments);
      return this.render();
    };

    ContextMenuView.prototype.render = function() {
      this.el.html(this.template);
      this.el.addClass(this.active_menu_class);
      this.position_active_menu(this.event);
      document.addEventListener("click", this.hide);
      $(Settings.id.paper).on('mousewheel', this.hide);
      window.onresize = this.hide;
      window.onkeyup = (function(_this) {
        return function(e) {
          if (e.keyCode === 27) {
            return _this.hide();
          }
        };
      })(this);
      return this.el.on("click [data-action]", (function(_this) {
        return function(ev) {
          var custom_event;
          _this.el.off('click [data-action]');
          custom_event = ev.target.dataset.action;
          Vent.vent(custom_event, _this.model, ev);
          console.log(custom_event + " element event triggered");
          return _this.hide();
        };
      })(this));
    };

    ContextMenuView.prototype.hide = function() {
      this.el.removeClass(this.active_menu_class);
      this.remove();
      return this.unbind();
    };

    ContextMenuView.prototype.position_active_menu = function(e) {
      var menuHeight, menuWidth, ref, windowHeight, windowWidth, x, y;
      ref = this.getPosition(e), x = ref.x, y = ref.y;
      menuWidth = this.el.offsetWidth + 4;
      menuHeight = this.el.offsetHeight + 4;
      windowWidth = window.innerWidth;
      windowHeight = window.innerHeight;
      if (windowWidth - x < menuWidth) {
        this.el.css('left', windowWidth - menuWidth + 'px');
      } else {
        this.el.css('left', x + 'px');
      }
      if (windowHeight - y < menuHeight) {
        this.el.css('top', windowHeight - menuHeight + 'px');
      } else {
        this.el.css('top', y + 'px');
      }
    };

    ContextMenuView.prototype.getPosition = function(e) {
      var posx, posy;
      posx = 0;
      posy = 0;
      if (e == null) {
        e = window.event;
      }
      if (e.pageX) {
        posx = e.pageX;
        posy = e.pageY;
      } else {
        posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
        posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
      }
      return {
        x: posx,
        y: posy - 12
      };
    };

    return ContextMenuView;

  })(Backbone.View);

  ContextMenu = {

    /*
    Usage:
    selector is the element to bind menu to
    menu_id is the id of menu div that is being bound to selector
    settings.context_menu = { str selector: str menu_id, ... }
     */
    active_menu_class: "context-menu--active",
    active_menu: void 0,
    init: function(settings) {
      var context, menu_id, selector;
      this.active_menu_class = settings.active_menu_class || this.active_menu_class;
      context = settings.context_menu;
      this.active_menu = void 0;
      for (selector in context) {
        menu_id = context[selector];
        this.context_listener.apply(this, [selector, menu_id]);
      }
      this.clickListener();
      this.keyupListener();
      this.resizeListener();
      this.scrollListener();
    },
    context_listener: function(selector, menu_id) {
      $(selector).on('contextmenu', function(e) {
        e.preventDefault();
        if (ContextMenu.active_menu) {
          ContextMenu.active_menu_off();
        }
        ContextMenu.menu_on(menu_id);
        ContextMenu.position_active_menu(e);
        return e.stopPropagation();
      });
    },
    active_menu_off: function() {
      if (ContextMenu.active_menu) {
        ContextMenu.active_menu.classList.remove(ContextMenu.active_menu_class);
        ContextMenu.active_menu = void 0;
      }
    },
    menu_on: function(menu_id) {
      ContextMenu.active_menu = document.querySelector(menu_id);
      ContextMenu.active_menu.classList.add(ContextMenu.active_menu_class);
    },
    position_active_menu: function(e) {
      var menuHeight, menuWidth, ref, windowHeight, windowWidth, x, y;
      ref = ContextMenu.getPosition(e), x = ref.x, y = ref.y;
      menuWidth = ContextMenu.active_menu.offsetWidth + 4;
      menuHeight = ContextMenu.active_menu.offsetHeight + 4;
      windowWidth = window.innerWidth;
      windowHeight = window.innerHeight;
      if (windowWidth - x < menuWidth) {
        ContextMenu.active_menu.style.left = windowWidth - menuWidth + 'px';
      } else {
        ContextMenu.active_menu.style.left = x + 'px';
      }
      if (windowHeight - y < menuHeight) {
        ContextMenu.active_menu.style.top = windowHeight - menuHeight + 'px';
      } else {
        ContextMenu.active_menu.style.top = y + 'px';
      }
    },
    getPosition: function(e) {
      var posx, posy;
      posx = 0;
      posy = 0;
      if (e == null) {
        e = window.event;
      }
      if (e.pageX) {
        posx = e.pageX;
        posy = e.pageY;
      } else {
        posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
        posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
      }
      return {
        x: posx,
        y: posy - 12
      };
    },
    clickListener: function() {
      return document.addEventListener("click", function(e) {
        ContextMenu.active_menu_off();
      });
    },
    keyupListener: function() {
      window.onkeyup = function(e) {
        if (e.keyCode === 27) {
          ContextMenu.active_menu_off();
        }
      };
    },
    resizeListener: function() {
      window.onresize = function(e) {
        ContextMenu.active_menu_off();
      };
    },
    scrollListener: function() {
      $('#myholder').on('mousewheel', function(e) {
        ContextMenu.active_menu_off();
      });
    }
  };

  Vent = (function() {
    function Vent() {
      _.extend(this, Backbone.Events);
    }

    Vent.prototype.register = function(handlers) {
      var event_handler, eventclass, eventname, handler, results;
      results = [];
      for (eventclass in handlers) {
        handler = handlers[eventclass];
        results.push((function() {
          var ref, results1;
          ref = handler['custom_events'];
          results1 = [];
          for (eventname in ref) {
            event_handler = ref[eventname];
            results1.push(this.listenTo(Backbone, eventclass + ":" + eventname, _.bind(event_handler, handler)));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    Vent.vent = function(custom_event) {
      var args, primary, secondary, tokens;
      tokens = custom_event.split(':');
      primary = tokens.slice(0, 2).join(':');
      secondary = tokens.slice(2).join(':');
      args = [].slice.call(arguments, 1);
      if (secondary !== "") {
        args.unshift(secondary);
      }
      args.unshift(primary);
      return Backbone.trigger.apply(Backbone, args);
    };

    Vent.passover = function() {
      var args, event_name, obj;
      args = [].slice.call(arguments, 2);
      event_name = arguments[0];
      obj = arguments[1];
      return obj.custom_events[event_name].apply(obj, args);
    };

    return Vent;

  })();

  module.exports = {
    bind_context_menus: bind_context_menus,
    custom_events: custom_events,
    ContextMenuView: ContextMenuView,
    ContextMenu: ContextMenu,
    Vent: Vent,
    GlobalGUI: GlobalGUI
  };

}).call(this);

//# sourceMappingURL=ui.js.map
