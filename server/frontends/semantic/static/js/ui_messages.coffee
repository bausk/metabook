class SessionDisconnectedMessage extends Backbone.View

    initialize: () ->
        SessionDisconnectedMessage.__super__.initialize.apply(this, arguments);
        templates = require('./templates')
        @template = templates.Messages.SessionDisconnected
        @render()

    show: =>
        @$el.find(".message").removeClass("hidden")

    hide: =>
        @$el.find(".message").addClass("hidden")

    render: =>
        @$el.html(@template)

module.exports = {SessionDisconnectedMessage}