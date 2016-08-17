# Context menu taken from
# https://github.com/callmenick/Custom-Context-Menu

Settings = require("./settings")

settings =
    active_menu_class: "context-menu--active"
    selector: "#context-menu"
    context_bindings:
        ".element": "#context-menu"
        "svg": "#context-menu2"
    templates:
        node: """<a href="#" class="item" data-action="graph:node:properties"><i class="fa fa-tasks"></i> Properties <div class="ui small inverted label">Ctrl+Enter</div></a>
        <a href="#" class="item" data-action="session:run"><i class="fa fa-play"></i> Run Node <div class="ui small inverted label">Ctrl+E</div></a>
        <a href="#" class="item" data-action="graph:node:update"><i class="fa fa-exchange"></i> Sync to Server <div class="ui small inverted label">Ctrl+D</div></a>
        <a href="#" class="item" data-action="graph:node:expand"><i class="fa fa-expand"></i> Expand & Edit <div class="ui small inverted label">Ctrl+D</div></a>
        <a href="#" class="item" data-action="graph:node:duplicate"><i class="fa fa-copy"></i> Duplicate <div class="ui small inverted label">Ctrl+D</div></a>
        <a href="#" class="item" data-action="graph:node:similar"><i class="fa fa-plus"></i> Select Similar <div class="ui small inverted label">Ctrl+D</div></a>
        <a href="#" class="item" data-action="graph:node:delete"><i class="fa fa-times"></i> Delete <div class="ui small inverted label">Ctrl+D</div></a>
        """
        blank: """<a href="#" class="item" data-action="graph:newnode"><i class="fa fa-eye"></i> New node <div class="ui small inverted label">Ctrl+D</div></a>
        <a href="#" class="item" data-action="model:solve"><i class="fa fa-edit"></i> Run <div class="ui small inverted label">Ctrl+E</div></a>
        <a href="#" class="item" data-action="graph:node:delete"><i class="fa fa-times"></i> Delete <div class="ui small inverted label">Ctrl+D</div></a>"""

bind_context_menus = () ->
    for selector, menu_id of settings.context_bindings
        @context_listener.apply @, [selector, menu_id]

custom_events = {
    'add': (cell) ->
        cell.$box.on( 'contextmenu', _.partialRight( (e, cell) ->
            # TODO suppress default, create view
            e.preventDefault()
            menu = new ContextMenuView(cell.model, {cell: cell, event: e, class: settings.active_menu_class, selector: settings.selector, template: settings.templates.node})
        , cell)
        )
    'blankmenu': (paper, e) ->
        e.preventDefault()
        menu = new ContextMenuView(paper.model, {event: e, class: settings.active_menu_class, selector: settings.selector, template: settings.templates.blank})
}

class GlobalGUI extends Backbone.View
    initialize: ->
        @listenTo Backbone, 'graph:notready', @dim
        @listenTo Backbone, 'graph:ready', @undim
    dim: ->
        $("#id2").dimmer({closable:false}).dimmer('show')
    undim: ->
        $("#id2").dimmer('hide')

class ContextMenuView extends Backbone.View

    initialize: (model, settings) ->
        @active_menu_class = settings.class
        @template = settings.template
        @el = $ settings.selector
        @event = settings.event
        @model = model
        @cell = settings.cell
        Backbone.View.prototype.initialize.apply(@, arguments)
        @render()

    render: ->
        @el.html(@template)
        @el.addClass(@active_menu_class)
        @position_active_menu(@event)
        document.addEventListener("click", @hide)
        $(Settings.id.paper).on 'mousewheel', @hide
        window.onresize = @hide
        window.onkeyup = (e) =>
            if e.keyCode == 27
                @hide()
        @el.on "click [data-action]", (ev) =>
            @el.off('click [data-action]')
            custom_event = ev.target.dataset.action
            Vent.vent custom_event, @model, ev
            console.log "#{custom_event} element event triggered"
            @hide()

    hide: =>
        @el.removeClass(@active_menu_class)
        @remove()
        @unbind()

    position_active_menu: (e) =>
        {x, y} = @getPosition(e)
        menuWidth = @el.offsetWidth + 4
        menuHeight = @el.offsetHeight + 4
        windowWidth = window.innerWidth
        windowHeight = window.innerHeight
        if windowWidth - x < menuWidth
            @el.css('left', windowWidth - menuWidth + 'px')
        else
            @el.css('left', x + 'px')
        if windowHeight - y < menuHeight
            @el.css('top', windowHeight - menuHeight + 'px')
        else
            @el.css('top', y + 'px')
        return

    getPosition: (e) =>
        posx = 0
        posy = 0
        e ?= window.event
        if e.pageX
            posx = e.pageX
            posy = e.pageY
        else
            posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
            posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
        { x: posx, y: posy - 12 }


ContextMenu = {

    ###
    Usage:
    selector is the element to bind menu to
    menu_id is the id of menu div that is being bound to selector
    settings.context_menu = { str selector: str menu_id, ... }
    ###
    active_menu_class: "context-menu--active"

    active_menu: undefined

    init: (settings) ->
        #instead of context listener, dispatch listeners by arguments
        @active_menu_class = settings.active_menu_class or this.active_menu_class
        context = settings.context_menu
        @active_menu = undefined
        for selector, menu_id of context
            @context_listener.apply @, [selector, menu_id]
        @clickListener()
        @keyupListener()
        @resizeListener()
        @scrollListener()
        return

    context_listener: (selector, menu_id) ->
        $(selector).on('contextmenu', (e) ->
            # 1) reset all menus to invisible
            # 2) toggle menu_id on
            # 3) position menu_id
            e.preventDefault()
            ContextMenu.active_menu_off() if ContextMenu.active_menu
            ContextMenu.menu_on(menu_id)
            ContextMenu.position_active_menu(e)
            e.stopPropagation()
        )
        return

    active_menu_off: ->
        if ContextMenu.active_menu
            ContextMenu.active_menu.classList.remove ContextMenu.active_menu_class
            ContextMenu.active_menu = undefined
        return

    menu_on: (menu_id) ->
        ContextMenu.active_menu = document.querySelector(menu_id)
        ContextMenu.active_menu.classList.add ContextMenu.active_menu_class
        return

    position_active_menu: (e) ->
        {x, y} = ContextMenu.getPosition(e)
        menuWidth = ContextMenu.active_menu.offsetWidth + 4
        menuHeight = ContextMenu.active_menu.offsetHeight + 4
        windowWidth = window.innerWidth
        windowHeight = window.innerHeight
        if windowWidth - x < menuWidth
            ContextMenu.active_menu.style.left = windowWidth - menuWidth + 'px'
        else
            ContextMenu.active_menu.style.left = x + 'px'
        if windowHeight - y < menuHeight
            ContextMenu.active_menu.style.top = windowHeight - menuHeight + 'px'
        else
            ContextMenu.active_menu.style.top = y + 'px'
        return

    getPosition: (e) ->
        posx = 0
        posy = 0
        e ?= window.event
        if e.pageX
            posx = e.pageX
            posy = e.pageY
        else
            posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
            posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
        { x: posx, y: posy - 12 }

    clickListener: ->
        document.addEventListener("click", (e) ->
            ContextMenu.active_menu_off()
            return
        )

    keyupListener: ->
        window.onkeyup = (e) ->
            if e.keyCode == 27
                ContextMenu.active_menu_off()
            return
        return

    resizeListener: ->
        window.onresize = (e) ->
            ContextMenu.active_menu_off()
            return
        return

    scrollListener: ->
        $('#myholder').on 'mousewheel', (e) ->
            ContextMenu.active_menu_off()
            return
        return

}

class Vent #extends Backbone.Events
    constructor: ->
        _.extend @, Backbone.Events
    register: (handlers) ->
        # super(@, arguments)
        # handlers have format: 'eventclass' : object['custom_events'][event] and we have to listen to eventclass:event
        for eventclass, handler of handlers
           for eventname, event_handler of handler['custom_events']
               @listenTo Backbone, eventclass + ":" + eventname, _.bind(event_handler, handler)
    @vent: (custom_event) ->
        tokens = custom_event.split(':')
        primary = tokens.slice(0,2).join(':')
        secondary = tokens.slice(2).join(':')
        args = [].slice.call(arguments, 1)
        if secondary != ""
            args.unshift(secondary)
        args.unshift(primary)
        Backbone.trigger.apply(Backbone, args)

    @passover: () ->
        args = [].slice.call(arguments, 2)
        event_name = arguments[0]
        obj = arguments[1]
        obj.custom_events[event_name].apply(obj, args)

module.exports = {bind_context_menus, custom_events, ContextMenuView, ContextMenu, Vent, GlobalGUI}