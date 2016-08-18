// Generated by CoffeeScript 1.10.0
(function(global, factory) {
  if (typeof define === 'function' && define.amd) {
    define([], factory);
  } else if (typeof module !== 'undefined' && module.exports) {
    module.exports = factory();
  } else {
    global.ReconnectingWebSocket = factory();
  }
})(this, function() {
  var ReconnectingWebSocket;
  ReconnectingWebSocket = function(url, protocols, options) {
    var eventTarget, forcedClose, generateEvent, key, self, settings, timedOut, ws;
    settings = {
      debug: false,
      automaticOpen: true,
      reconnectInterval: 1000,
      maxReconnectInterval: 30000,
      reconnectDecay: 1.5,
      timeoutInterval: 2000,
      maxReconnectAttempts: null,
      binaryType: 'blob'
    };

    /**
     * This function generates an event that is compatible with standard
     * compliant browsers and IE9 - IE11
     *
     * This will prevent the error:
     * Object doesn't support this action
     *
     * http://stackoverflow.com/questions/19345392/why-arent-my-parameters-getting-passed-through-to-a-dispatched-event/19345563#19345563
     * @param s String The name that the event should use
     * @param args Object an optional object that the event will use
     */
    generateEvent = function(s, args) {
      var evt;
      evt = document.createEvent('CustomEvent');
      evt.initCustomEvent(s, false, false, args);
      return evt;
    };
    if (!options) {
      options = {};
    }
    for (key in settings) {
      if (typeof options[key] !== 'undefined') {
        this[key] = options[key];
      } else {
        this[key] = settings[key];
      }
    }

    /** The URL as resolved by the constructor. This is always an absolute URL. Read only. */
    this.url = url;

    /** The number of attempted reconnects since starting, or the last successful connection. Read only. */
    this.reconnectAttempts = 0;

    /**
     * The current state of the connection.
     * Can be one of: WebSocket.CONNECTING, WebSocket.OPEN, WebSocket.CLOSING, WebSocket.CLOSED
     * Read only.
     */
    this.readyState = WebSocket.CONNECTING;

    /**
     * A string indicating the name of the sub-protocol the server selected; this will be one of
     * the strings specified in the protocols parameter when creating the WebSocket object.
     * Read only.
     */
    this.protocol = null;
    self = this;
    ws = void 0;
    forcedClose = false;
    timedOut = false;
    eventTarget = document.createElement('div');
    eventTarget.addEventListener('open', function(event) {
      self.onopen(event);
    });
    eventTarget.addEventListener('close', function(event) {
      self.onclose(event);
    });
    eventTarget.addEventListener('connecting', function(event) {
      self.onconnecting(event);
    });
    eventTarget.addEventListener('message', function(event) {
      self.onmessage(event);
    });
    eventTarget.addEventListener('error', function(event) {
      self.onerror(event);
    });
    this.addEventListener = eventTarget.addEventListener.bind(eventTarget);
    this.removeEventListener = eventTarget.removeEventListener.bind(eventTarget);
    this.dispatchEvent = eventTarget.dispatchEvent.bind(eventTarget);
    this.open = function(reconnectAttempt) {
      var localWs, timeout;
      ws = new WebSocket(self.url, protocols || []);
      ws.binaryType = this.binaryType;
      if (reconnectAttempt) {
        if (this.maxReconnectAttempts && this.reconnectAttempts > this.maxReconnectAttempts) {
          return;
        }
      } else {
        eventTarget.dispatchEvent(generateEvent('connecting'));
        this.reconnectAttempts = 0;
      }
      Backbone.trigger("session:connecting", this);
      console.log("<session:connecting>");
      if (self.debug || ReconnectingWebSocket.debugAll) {
        console.debug('ReconnectingWebSocket', 'attempt-connect', self.url);
      }
      localWs = ws;
      timeout = setTimeout((function() {
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'connection-timeout', self.url);
        }
        timedOut = true;
        localWs.close();
        timedOut = false;
      }), self.timeoutInterval);
      ws.onopen = function(event) {
        var e;
        clearTimeout(timeout);
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'onopen', self.url);
        }
        self.protocol = ws.protocol;
        self.readyState = WebSocket.OPEN;
        self.reconnectAttempts = 0;
        e = generateEvent('open');
        e.isReconnect = reconnectAttempt;
        reconnectAttempt = false;
        eventTarget.dispatchEvent(e);
      };
      ws.onclose = function(event) {
        var timeout;
        var e;
        clearTimeout(timeout);
        ws = null;
        if (forcedClose) {
          self.readyState = WebSocket.CLOSED;
          eventTarget.dispatchEvent(generateEvent('close'));
        } else {
          self.readyState = WebSocket.CONNECTING;
          e = generateEvent('connecting');
          e.code = event.code;
          e.reason = event.reason;
          e.wasClean = event.wasClean;
          eventTarget.dispatchEvent(e);
          if (!reconnectAttempt && !timedOut) {
            if (self.debug || ReconnectingWebSocket.debugAll) {
              console.debug('ReconnectingWebSocket', 'onclose', self.url);
            }
            eventTarget.dispatchEvent(generateEvent('close'));
          }
          timeout = self.reconnectInterval * Math.pow(self.reconnectDecay, self.reconnectAttempts);
          console.log("<session:waiting> " + (timeout > self.maxReconnectInterval ? self.maxReconnectInterval : timeout));
          Backbone.trigger("session:waiting", this, timeout > self.maxReconnectInterval ? self.maxReconnectInterval : timeout);
          setTimeout((function() {
            self.reconnectAttempts++;
            self.open(true);
          }), timeout > self.maxReconnectInterval ? self.maxReconnectInterval : timeout);
        }
      };
      ws.onmessage = function(event) {
        var e;
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'onmessage', self.url, event.data);
        }
        e = generateEvent('message');
        e.data = event.data;
        eventTarget.dispatchEvent(e);
      };
      ws.onerror = function(event) {
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'onerror', self.url, event);
        }
        eventTarget.dispatchEvent(generateEvent('error'));
        Backbone.trigger("connection:error", this);
        console.log("<session:error>");
      };
    };
    if (this.automaticOpen === true) {
      this.open(false);
    }

    /**
     * Transmits data to the server over the WebSocket connection.
     *
     * @param data a text string, ArrayBuffer or Blob to send to the server.
     */
    this.send = function(data) {
      if (ws) {
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'send', self.url, data);
        }
        return ws.send(data);
      } else {
        throw 'INVALID_STATE_ERR : Pausing to reconnect websocket';
      }
    };

    /**
     * Closes the WebSocket connection or connection attempt, if any.
     * If the connection is already CLOSED, this method does nothing.
     */
    this.close = function(code, reason) {
      if (typeof code === 'undefined') {
        code = 1000;
      }
      forcedClose = true;
      if (ws) {
        ws.close(code, reason);
      }
    };

    /**
     * Additional public API method to refresh the connection if still open (close, re-open).
     * For example, if the app suspects bad data / missed heart beats, it can try to refresh.
     */
    this.refresh = function() {
      if (ws) {
        ws.close();
      }
    };
  };
  if (!('WebSocket' in window)) {
    return;
  }

  /**
   * An event listener to be called when the WebSocket connection's readyState changes to OPEN;
   * this indicates that the connection is ready to send and receive data.
   */
  ReconnectingWebSocket.prototype.onopen = function(event) {};

  /** An event listener to be called when the WebSocket connection's readyState changes to CLOSED. */
  ReconnectingWebSocket.prototype.onclose = function(event) {};

  /** An event listener to be called when a connection begins being attempted. */
  ReconnectingWebSocket.prototype.onconnecting = function(event) {};

  /** An event listener to be called when a message is received from the server. */
  ReconnectingWebSocket.prototype.onmessage = function(event) {};

  /** An event listener to be called when an error occurs. */
  ReconnectingWebSocket.prototype.onerror = function(event) {};

  /**
   * Whether all instances of ReconnectingWebSocket should log debug messages.
   * Setting this to true is the equivalent of setting all instances of ReconnectingWebSocket.debug to true.
   */
  ReconnectingWebSocket.debugAll = false;
  ReconnectingWebSocket.CONNECTING = WebSocket.CONNECTING;
  ReconnectingWebSocket.OPEN = WebSocket.OPEN;
  ReconnectingWebSocket.CLOSING = WebSocket.CLOSING;
  ReconnectingWebSocket.CLOSED = WebSocket.CLOSED;
  return ReconnectingWebSocket;
});

//# sourceMappingURL=websocket.js.map
