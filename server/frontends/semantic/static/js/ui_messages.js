// Generated by CoffeeScript 1.10.0
var SessionDisconnectedMessage,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

SessionDisconnectedMessage = (function(superClass) {
  extend(SessionDisconnectedMessage, superClass);

  function SessionDisconnectedMessage() {
    this.render = bind(this.render, this);
    this.hide = bind(this.hide, this);
    this.show = bind(this.show, this);
    return SessionDisconnectedMessage.__super__.constructor.apply(this, arguments);
  }

  SessionDisconnectedMessage.prototype.initialize = function() {
    var templates;
    SessionDisconnectedMessage.__super__.initialize.apply(this, arguments);
    templates = require('./templates');
    this.template = templates.Messages.SessionDisconnected;
    return this.render();
  };

  SessionDisconnectedMessage.prototype.show = function() {
    return this.$el.find(".message").removeClass("hidden");
  };

  SessionDisconnectedMessage.prototype.hide = function() {
    return this.$el.find(".message").addClass("hidden");
  };

  SessionDisconnectedMessage.prototype.render = function() {
    return this.$el.html(this.template);
  };

  return SessionDisconnectedMessage;

})(Backbone.View);

module.exports = {
  SessionDisconnectedMessage: SessionDisconnectedMessage
};

//# sourceMappingURL=ui_messages.js.map
