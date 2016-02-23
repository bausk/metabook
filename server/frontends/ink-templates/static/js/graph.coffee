messageContainer = document.getElementById("messages")

WebSocketTest = ->
    if ("WebSocket" in window)
        messageContainer.innerHTML = "WebSocket is supported by your Browser!"
        ws = new WebSocket("ws://localhost:8585/sessions/?Id=123456789")
        ws.onopen = ->
            ws.send("Message to send")
        ws.onmessage = (evt) ->
            received_msg = evt.data
            messageContainer.innerHTML = "Message is received..." + received_msg

        ws.onclose = ->
            messageContainer.innerHTML = "Connection is closed..."

    else
        messageContainer.innerHTML = "WebSocket NOT supported by your Browser!"

