#
# Context menu taken from
# https://github.com/callmenick/Custom-Context-Menu

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

metabook.ui.add = (e) ->
    alert("add")

metabook.ui.edit = (e) ->
    alert("edit")

metabook.ui.delete = (e) ->
    alert("delete" + e.pageX)

metabook.ui.save = (e) ->
    alert('save')

$("[data-action]").click( (evt) ->
    action = $(this).data('action')
    if Settings.ui.actions.hasOwnProperty(action)
        Settings.ui.actions[action](evt)
)