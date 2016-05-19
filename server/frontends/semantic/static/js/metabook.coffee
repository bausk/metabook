metabook.models = {}
metabook.views = {}

class metabook.models.CellModel extends Backbone.Model
    initialize: (attributes, data) ->

    update_data: (graph_cell) ->
        d = "\n"
        content = _.map(graph_cell.get('content').split(d), (el) ->
            el + d
        )
        if _.last(content) == d
            content.pop()
        @set('source', content)
        @set('inPorts', graph_cell.get('inPorts'))
        @set('outPorts', graph_cell.get('outPorts'))
        @set('position', graph_cell.get('position'))


class metabook.models.LinkModel extends Backbone.Model
    initialize: (attributes, data) ->
    update_data: (graph_link) ->

class metabook.models.CellCollection extends Backbone.Collection
    model: metabook.models.CellModel

class metabook.models.LinkCollection extends Backbone.Collection
    model: metabook.models.LinkModel


class metabook.models.MetabookModel extends Backbone.Model
    initialize: (attributes, {json_graph}) ->

        cell_collection = new metabook.models.CellCollection()
        for cell in json_graph.cells
            cell_model = new metabook.models.CellModel(cell)
            cell_collection.add(cell_model)
        @set('cells', cell_collection)

        link_collection = new metabook.models.LinkCollection()
        for link_model in json_graph.links
            link_collection.add(link_model)

        @set('links', link_collection)

        @set('tabs', json_graph.tabs)
        @set('results', json_graph.results)
        @set('id', json_graph.id)

    custom_events:
        'save': (caller, ev) ->
            data = JSON.stringify(this.attributes)
            # data = JSON.stringify(Obj.graph) #just kidding
            call_type = if metabook.util.get_parameter('new') then 'POST' else 'PUT'
            $.ajax(
                url: metabook.uri.file.endpoint + metabook.uri.file.path
                type: call_type
                data: data
                success: _.bind(((json_data, status, xhr) ->
                    console.log('Succesfully uploaded data')
                    if json_data.new_path
                        history.replaceState(null, null, "/" + json_data.new_path)
                        metabook.uri.file.path = json_data.new_path
                        metabook.uri.file.name = json_data.new_name
                ), this)
                error: error_graph
            )
        'solve': (caller, ev) ->
            @session.solve_all(@, ev)

    data = {
        get_cells: _.partial(metabook.data.get_cells, @)
        get_links: _.partial(metabook.data.get_links, @)
    }


class metabook.views.MenuView extends Backbone.View

    events:
        "click [data-action]": (ev) ->
            custom_event = ev.target.dataset.action
            Backbone.trigger custom_event, @model, ev
            console.log "MenuView event triggered"