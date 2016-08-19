class SessionDisconnectedMessage extends Backbone.View

    initialize: () ->
        SessionDisconnectedMessage.__super__.initialize.apply(this, arguments);
        @templates = require('./templates')
        @template = @templates.Messages.SessionDisconnected
        @render()
        @listenTo Backbone, "connection:closed", @show
        @listenTo Backbone, "websocket:wait", @start_timer
        @listenTo Backbone, "connection:open", @hide

    render: =>


    show: (ev) =>
        @$el.html(@template)
        @$el.find(".message").addClass("hidden")
        @$el.find(".message").transition("fade")

    hide: =>
        @$el.find(".message").removeClass("hidden")
        @$el.find(".message").transition("fade")

    start_timer: (ev, time_milliseconds) =>
        plaintext = @$el.find(@templates.Messages.SessionDisconnectedTimerEl)
        plaintext.html(@templates.Messages.SessionDisconnectedTimer)
        timer_part = plaintext.find('span')
        timer = time_milliseconds / 1000
        @interval = setInterval( (callback) ->
            #console.log timer
            minutes = parseInt(timer / 60, 10)
            seconds = parseInt(timer % 60, 10)

            minutes = if minutes < 10 then "0" + minutes else minutes
            seconds = if seconds < 10 then "0" + seconds else seconds

            timer_part.html(" in " + minutes + ":" + seconds)

            if --timer < 0
                callback()

        , 1000, () => clearInterval(@interval))

module.exports = {SessionDisconnectedMessage}