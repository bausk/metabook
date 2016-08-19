// Generated by CoffeeScript 1.10.0
(function() {
  var SessionDisconnectedMessage,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  SessionDisconnectedMessage = (function(superClass) {
    extend(SessionDisconnectedMessage, superClass);

    function SessionDisconnectedMessage() {
      this.start_timer = bind(this.start_timer, this);
      this.hide = bind(this.hide, this);
      this.show = bind(this.show, this);
      this.render = bind(this.render, this);
      return SessionDisconnectedMessage.__super__.constructor.apply(this, arguments);
    }

    SessionDisconnectedMessage.prototype.initialize = function() {
      SessionDisconnectedMessage.__super__.initialize.apply(this, arguments);
      this.templates = require('./templates');
      this.template = this.templates.Messages.SessionDisconnected;
      this.render();
      this.listenTo(Backbone, "connection:closed", this.show);
      this.listenTo(Backbone, "websocket:wait", this.start_timer);
      return this.listenTo(Backbone, "connection:open", this.hide);
    };

    SessionDisconnectedMessage.prototype.render = function() {};

    SessionDisconnectedMessage.prototype.show = function(ev) {
      this.$el.html(this.template);
      this.$el.find(".message").addClass("hidden");
      return this.$el.find(".message").transition("fade");
    };

    SessionDisconnectedMessage.prototype.hide = function() {
      this.$el.find(".message").removeClass("hidden");
      return this.$el.find(".message").transition("fade");
    };

    SessionDisconnectedMessage.prototype.start_timer = function(ev, time_milliseconds) {
      var plaintext, timer, timer_part;
      plaintext = this.$el.find(this.templates.Messages.SessionDisconnectedTimerEl);
      plaintext.html(this.templates.Messages.SessionDisconnectedTimer);
      timer_part = plaintext.find('span');
      timer = time_milliseconds / 1000;
      return this.interval = setInterval(function(callback) {
        var minutes, seconds;
        minutes = parseInt(timer / 60, 10);
        seconds = parseInt(timer % 60, 10);
        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;
        timer_part.html(" in " + minutes + ":" + seconds);
        if (--timer < 0) {
          return callback();
        }
      }, 1000, (function(_this) {
        return function() {
          return clearInterval(_this.interval);
        };
      })(this));
    };

    return SessionDisconnectedMessage;

  })(Backbone.View);

  module.exports = {
    SessionDisconnectedMessage: SessionDisconnectedMessage
  };

}).call(this);

//# sourceMappingURL=ui_messages.js.map
