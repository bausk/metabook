metabook = {
    session: {}
    messages: {}
    ui: {}
    api:
        file: {}
    models: {}
    views: {}
    defaults: {}
    options: {}
    events: {}
}

metabook.api.get_template = (success, error) ->
    $.ajax(
        url: metabook.api.template_endpoint + metabook.api.file.path
        type: 'GET'
        success: success
        error: error
    )

metabook.api.get_file = (success, error) ->
    $.ajax(
        url: metabook.api.file.endpoint + metabook.api.file.path
        type: 'GET'
        success: success
        error: error
    )

metabook.api.get_ajax_data = (data_uri, success, error) ->
    $.ajax(
        url: data_uri
        type: 'GET'
        success: success
        error: error
    )

metabook.api.is_good_form = (json_data) ->
    if typeof json_data is 'object'
        if 'metadata' of json_data
            if 'metabook' of json_data.metadata
                if 'links' of json_data.metadata.metabook
                    return true
    return false

metabook.defaults =
    cell: (json_data) ->
        if metabook.api.is_good_form(json_data)
            return json_data.metadata.metabook.defaults.cell
        throw new Error()


class metabook.models.CellModel extends Backbone.Model
    initialize: (attributes, data) ->
        cell_metadata = attributes.metadata if attributes.metadata?
        if data.generate_id
            _.merge(cell_metadata, data.cell_template.metadata)
            cell_metadata.metabook.id = joint.util.uuid()
        _.merge(cell_metadata, data.extension.metadata)
        @set('metadata', cell_metadata)

    update_data: (graph_cell) ->
        d = "\n"
        content = _.map(graph_cell.get('content').split(d), (el) ->
            el + d
        )
        if _.last(content) == d
            content.pop()
        @set('source', content)
        metadata = _.clone(@get('metadata'))
        metadata.metabook.inPorts = graph_cell.get('inPorts')
        metadata.metabook.outPorts = graph_cell.get('outPorts')
        metadata.metabook.position = graph_cell.get('position')
        @set('metadata', metadata)

class metabook.models.LinkModel extends Backbone.Model
    initialize: (attributes, data) ->
    update_data: (graph_link) ->

class metabook.models.CellCollection extends Backbone.Collection
    model: metabook.models.CellModel

class metabook.models.LinkCollection extends Backbone.Collection
    model: metabook.models.LinkModel


class metabook.models.MetabookModel extends Backbone.Model
    initialize: (attributes, data) ->

        # The point of init is to construct proper structure from data.json
        # Taking into account that cells are clean but links may need generation depending on format
        #data.template contains template & defaults

        elements = []
        links = []

        # do we need to generate id's?
        # 2 cases: non-native format or new metabook
        extension = {}
        if metabook.options.new == true and data.create_from == "native"
            #metadata should be already present
            generate_id = true
            cell_template = metabook.defaults.cell(data.json)
        else
            if data.create_from != "native"

                generate_id = true
                _.merge(data.json.metadata.metabook, data.template.metadata.metabook)
                cell_template = metabook.defaults.cell(data.template)
            else
                generate_id = false
                cell_template = {}
                # other cases is opening an existing well-formed metabook, so no cell_template


        cell_collection = new metabook.models.CellCollection()

        increment_x = 500
        increment_y = 20
        x = 0
        y = 0
        for generic_cell in data.json.cells
            if data.create_from != "native"
                extension = {
                    metadata:
                        metabook:
                            position: {x, y}
                }
                x += increment_x
                y += increment_y
            cell_model = new metabook.models.CellModel(generic_cell, {generate_id, cell_template, extension})
            cell_collection.add(cell_model)

        metadata = undefined
        prev_cell = undefined

        link_collection = new metabook.models.LinkCollection()

        if data.create_from != "native"
            code_cells = cell_collection.filter({cell_type: "code"})

            for code_cell in code_cells
                if prev_cell
                    prev_cell_id = prev_cell.get("metadata").metabook.id
                    curr_cell_id = code_cell.get("metadata").metabook.id
                    link_model = new metabook.models.LinkModel(
                        source:
                            id: prev_cell_id
                            port: 'out:locals'
                        target:
                            id: curr_cell_id
                            port: 'in:locals'
                        id: joint.util.uuid()
                    )
                    link_collection.add(link_model)
                prev_cell = code_cell

            # this is a mess
            metadata = data.template.metadata
            # metadata.metabook.id = joint.util.uuid()

        else
            for link in data.json.metadata.metabook.links
                link_model = new metabook.models.LinkModel(link)
                link_collection.add(link_model)

            metadata = data.json.metadata
        if generate_id == true
            metadata.metabook.id = joint.util.uuid()

        metadata.metabook.links = link_collection
        @set('cells', cell_collection)
        @set('nbformat', data.json.nbformat)
        @set('nbformat_minor', data.json.nbformat_minor)
        @set('metadata', metadata)

        if metadata.metabook.id
            @set('id', metadata.metabook.id)

    custom_events:
        'save': (caller, ev) ->
            data = JSON.stringify(this.attributes)
            # data = JSON.stringify(Obj.graph) #just kidding
            call_type = if metabook.options.new then 'POST' else 'PUT'
            $.ajax(
                url: metabook.api.file.endpoint + metabook.api.file.path
                type: call_type
                data: data
                success: _.bind(((json_data, status, xhr) ->
                    alert('Succesfully uploaded data.')
                    if json_data.new_id
                        @set('id', json_data.new_id)
                        history.replaceState(null, null, "/" + json_data.new_path)
                        # update api/file/path
                        metabook.api.file.path = json_data.new_path
                        metabook.options.new = false
                        metabook.api.file.name = json_data.new_name
                ), this)
                error: error_graph
            )
        'solve': (caller, ev) ->
            @session.solve_all(@, ev)


class metabook.views.MenuView extends Backbone.View

    events:
        "click [data-action]": (ev) ->
            custom_event = ev.target.dataset.action
            Backbone.trigger custom_event, @model, ev
            console.log "MenuView event triggered"