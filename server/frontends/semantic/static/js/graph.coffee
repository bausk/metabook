WebSocketTest = undefined

( ->

    messageContainer = $("#messages")

    WebSocketTest = ->
        messageContainer.innerHTML = "WebSocket is supported by your Browser!"
        ws = new WebSocket("ws://localhost:8585/api/session/guise?Id=123456789")
        ws.onopen = ->
            ws.send("Message to send")
        ws.onmessage = (evt) ->
            received_msg = evt.data
            $(messageContainer).text("Message is received..." + received_msg)
        ws.onclose = ->
            $(messageContainer).text("Connection is closed...")



    $('#bConnect').on("click", WebSocketTest)

).call this