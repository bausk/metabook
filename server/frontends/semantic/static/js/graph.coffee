$(document).ready ->
    WebSocketTest    = undefined

    messageContainer = $("#messages")

    datastore = Backbone.Model.extend({
        websocket: null

    })

    WebSocketTest = (ev) ->
        messageContainer.text("WebSocket is supported by your Browser!")
        ws = new WebSocket("ws://" + window.location.host + "/api/session/guise?Id=123456789")

        ws.onopen = ->
            $('#bSend').on("click", ->
                ws.send("New message")
            )
            $('#bClose').on("click", (ev) ->
                ws.close()
                $(messageContainer).text("Connection is forcefully closed")
                $(ev.target).addClass("disabled");
                $('#bSend').addClass("disabled");
                $('#bConnect').removeClass("disabled");
                )
            $('#bClose').removeClass("disabled")
            $('#bSend').removeClass("disabled")
            $(ev.target).addClass("disabled");
        ws.onmessage = (evt) ->
            received_msg = evt.data
            $(messageContainer).text("Message is received..." + received_msg)
        ws.onclose = ->
            #$(messageContainer).text("Connection is closed...")


    $('#bConnect').on("click", WebSocketTest)



    makeCounter = ->
        count = 0
        {increment: -> count++
        getCount:  -> count}

    counter = makeCounter()

    $('#bTest1').on("click", ->
        counter.increment()
        alert(counter.getCount())
    )


