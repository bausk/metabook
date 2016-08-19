((global, factory) ->
  if typeof define == 'function' and define.amd
    define [], factory
  else if typeof module != 'undefined' and module.exports
    module.exports = factory()
  else
    global.ReconnectingWebSocket = factory()
  return
) this, ->

  ReconnectingWebSocket = (url, protocols, options) ->
    # Default settings
    settings =
      debug: false
      automaticOpen: true
      reconnectInterval: 1000
      maxReconnectInterval: 30000
      reconnectDecay: 1.5
      timeoutInterval: 2000
      maxReconnectAttempts: null
      binaryType: 'blob'

    ###*
    # This function generates an event that is compatible with standard
    # compliant browsers and IE9 - IE11
    #
    # This will prevent the error:
    # Object doesn't support this action
    #
    # http://stackoverflow.com/questions/19345392/why-arent-my-parameters-getting-passed-through-to-a-dispatched-event/19345563#19345563
    # @param s String The name that the event should use
    # @param args Object an optional object that the event will use
    ###

    generateEvent = (s, args) ->
      evt = document.createEvent('CustomEvent')
      evt.initCustomEvent s, false, false, args
      evt

    if !options
      options = {}
    # Overwrite and define settings with options if they exist.
    for key of settings
      if typeof options[key] != 'undefined'
        @[key] = options[key]
      else
        @[key] = settings[key]
    # These should be treated as read-only properties

    ###* The URL as resolved by the constructor. This is always an absolute URL. Read only. ###

    @url = url

    ###* The number of attempted reconnects since starting, or the last successful connection. Read only. ###

    @reconnectAttempts = 0

    ###*
    # The current state of the connection.
    # Can be one of: WebSocket.CONNECTING, WebSocket.OPEN, WebSocket.CLOSING, WebSocket.CLOSED
    # Read only.
    ###

    @readyState = WebSocket.CONNECTING

    ###*
    # A string indicating the name of the sub-protocol the server selected; this will be one of
    # the strings specified in the protocols parameter when creating the WebSocket object.
    # Read only.
    ###

    @protocol = null
    # Private state variables
    self = this
    ws = undefined
    forcedClose = false
    timedOut = false
    eventTarget = document.createElement('div')
    # Wire up "on*" properties as event handlers
    eventTarget.addEventListener 'open', (event) ->
      self.onopen event
      return
    eventTarget.addEventListener 'close', (event) ->
      self.onclose event
      return
    eventTarget.addEventListener 'connecting', (event) ->
      self.onconnecting event
      return
    eventTarget.addEventListener 'message', (event) ->
      self.onmessage event
      return
    eventTarget.addEventListener 'error', (event) ->
      self.onerror event
      return
    # Expose the API required by EventTarget
    @addEventListener = eventTarget.addEventListener.bind(eventTarget)
    @removeEventListener = eventTarget.removeEventListener.bind(eventTarget)
    @dispatchEvent = eventTarget.dispatchEvent.bind(eventTarget)

    @open = (reconnectAttempt) ->
      ws = new WebSocket(self.url, protocols or [])
      ws.binaryType = @binaryType
      if reconnectAttempt
        if @maxReconnectAttempts and @reconnectAttempts > @maxReconnectAttempts
          return
      else
        eventTarget.dispatchEvent generateEvent('connecting')
        @reconnectAttempts = 0
      Backbone.trigger "websocket:connecting", @
      console.log "<websocket:connecting>"
      if self.debug or ReconnectingWebSocket.debugAll
        console.debug 'ReconnectingWebSocket', 'attempt-connect', self.url
      localWs = ws
      timeout = setTimeout((->
        if self.debug or ReconnectingWebSocket.debugAll
          console.debug 'ReconnectingWebSocket', 'connection-timeout', self.url
        timedOut = true
        localWs.close()
        timedOut = false
        return
      ), self.timeoutInterval)

      ws.onopen = (event) ->
        clearTimeout timeout
        if self.debug or ReconnectingWebSocket.debugAll
          console.debug 'ReconnectingWebSocket', 'onopen', self.url
        self.protocol = ws.protocol
        self.readyState = WebSocket.OPEN
        self.reconnectAttempts = 0
        e = generateEvent('open')
        e.isReconnect = reconnectAttempt
        reconnectAttempt = false
        eventTarget.dispatchEvent e
        return

      ws.onclose = (event) ->
        `var timeout`
        clearTimeout timeout
        ws = null
        if forcedClose
          self.readyState = WebSocket.CLOSED
          eventTarget.dispatchEvent generateEvent('close')
        else
          self.readyState = WebSocket.CONNECTING
          e = generateEvent('connecting')
          e.code = event.code
          e.reason = event.reason
          e.wasClean = event.wasClean
          eventTarget.dispatchEvent e
          if !reconnectAttempt and !timedOut
            if self.debug or ReconnectingWebSocket.debugAll
              console.debug 'ReconnectingWebSocket', 'onclose', self.url
            eventTarget.dispatchEvent generateEvent('close')
          timeout = self.reconnectInterval * self.reconnectDecay ** self.reconnectAttempts
          console.log "<websocket:wait " + if timeout > self.maxReconnectInterval then self.maxReconnectInterval else timeout
          Backbone.trigger "websocket:wait", @, if timeout > self.maxReconnectInterval then self.maxReconnectInterval else timeout
          setTimeout (->
            self.reconnectAttempts++
            self.open true
            return
          ), if timeout > self.maxReconnectInterval then self.maxReconnectInterval else timeout
        return

      ws.onmessage = (event) ->
        if self.debug or ReconnectingWebSocket.debugAll
          console.debug 'ReconnectingWebSocket', 'onmessage', self.url, event.data
        e = generateEvent('message')
        e.data = event.data
        eventTarget.dispatchEvent e
        return

      ws.onerror = (event) ->
        if self.debug or ReconnectingWebSocket.debugAll
          console.debug 'ReconnectingWebSocket', 'onerror', self.url, event
        eventTarget.dispatchEvent generateEvent('error')
        Backbone.trigger "websocket:error", @
        console.log "websocket:wait"
        return

      return

    # Whether or not to create a websocket upon instantiation
    if @automaticOpen == true
      @open false

    ###*
    # Transmits data to the server over the WebSocket connection.
    #
    # @param data a text string, ArrayBuffer or Blob to send to the server.
    ###

    @send = (data) ->
      if ws
        if self.debug or ReconnectingWebSocket.debugAll
          console.debug 'ReconnectingWebSocket', 'send', self.url, data
        return ws.send(data)
      else
        throw 'INVALID_STATE_ERR : Pausing to reconnect websocket'
      return

    ###*
    # Closes the WebSocket connection or connection attempt, if any.
    # If the connection is already CLOSED, this method does nothing.
    ###

    @close = (code, reason) ->
      # Default CLOSE_NORMAL code
      if typeof code == 'undefined'
        code = 1000
      forcedClose = true
      if ws
        ws.close code, reason
      return

    ###*
    # Additional public API method to refresh the connection if still open (close, re-open).
    # For example, if the app suspects bad data / missed heart beats, it can try to refresh.
    ###

    @refresh = ->
      if ws
        ws.close()
      return

    return

  if !('WebSocket' of window)
    return

  ###*
  # An event listener to be called when the WebSocket connection's readyState changes to OPEN;
  # this indicates that the connection is ready to send and receive data.
  ###

  ReconnectingWebSocket::onopen = (event) ->

  ###* An event listener to be called when the WebSocket connection's readyState changes to CLOSED. ###

  ReconnectingWebSocket::onclose = (event) ->

  ###* An event listener to be called when a connection begins being attempted. ###

  ReconnectingWebSocket::onconnecting = (event) ->

  ###* An event listener to be called when a message is received from the server. ###

  ReconnectingWebSocket::onmessage = (event) ->

  ###* An event listener to be called when an error occurs. ###

  ReconnectingWebSocket::onerror = (event) ->

  ###*
  # Whether all instances of ReconnectingWebSocket should log debug messages.
  # Setting this to true is the equivalent of setting all instances of ReconnectingWebSocket.debug to true.
  ###

  ReconnectingWebSocket.debugAll = false
  ReconnectingWebSocket.CONNECTING = WebSocket.CONNECTING
  ReconnectingWebSocket.OPEN = WebSocket.OPEN
  ReconnectingWebSocket.CLOSING = WebSocket.CLOSING
  ReconnectingWebSocket.CLOSED = WebSocket.CLOSED
  ReconnectingWebSocket

# ---
# generated by js2coffee 2.2.0