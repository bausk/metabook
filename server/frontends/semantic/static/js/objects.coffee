imports =
    data: require("./data")
    util: require("./util")



class CellModel extends Backbone.Model
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


class LinkModel extends Backbone.Model
    initialize: (attributes, data) ->
    update_data: (graph_link) ->

class ApplicationState extends Backbone.Model
    initialize: (attributes, data) ->
        @on('change:graph_ready', @graph_ready, this)

    graph_ready: () ->



class CellCollection extends Backbone.Collection
    model: CellModel

class LinkCollection extends Backbone.Collection
    model: LinkModel


class MetabookModel extends Backbone.Model
    initialize: (attributes) ->
        MetabookModel.__super__.initialize.apply(this, arguments);
        cell_collection = new CellCollection()
        link_collection = new LinkCollection()
        @set('cells', cell_collection)
        @set('links', link_collection)
        Backbone.trigger 'metabook:notready', @



    connect: (message) =>
        cell_collection = @get('cells')
        json_graph = message.content
        for cell in json_graph.cells
            cell_model = new CellModel(cell)
            cell_collection.add(cell_model)
        @set('cells', cell_collection)

        link_collection = @get('links')
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
            call_type = if imports.util.get_parameter('new') then 'POST' else 'PUT'
            $.ajax(
                url: config.file.endpoint + config.file.path
                type: call_type
                data: data
                success: _.bind(((json_data, status, xhr) ->
                    console.log('Succesfully uploaded data')
                    if json_data.new_path
                        history.replaceState(null, null, "/" + json_data.new_path)
                        config.file.path = json_data.new_path
                        config.file.name = json_data.new_name
                ), this)
                error: error_graph
            )
        'solve': (caller, ev) ->
            @session.solve_all(@, ev)

    data: {
        get_cells: _.partial(imports.data.get_cells, @)
        get_links: _.partial(imports.data.get_links, @)
    }


class MenuView extends Backbone.View

    events:
        "click [data-action]": (ev) ->
            custom_event = ev.target.dataset.action
            Backbone.trigger custom_event, @model, ev
            console.log "MenuView event triggered"

class DetailsView extends Backbone.View

    template: """
        <div class="ui modal" style="top:100px">
        <div class="header">
          Node Properties: FACB345
        </div>
        <div class="content">
          <div class="ui form properties">
            <h4 class="ui dividing header">Type chain: </h4>
            <h4 class="ui dividing header">Tags: </h4>
            <div class="ui three column centered divided grid">
                <div class="row">
                    <div class="ui four wide column">
                                  <label>Inputs:</label>
                    </div>
                    <div class="ui eight wide column">
                                  <label>Code:</label><br/>
                        <textarea class="properties">blehbleh bleh</textarea>
                    </div>
                    <div class="ui four wide column">
                                  <label>Outputs:</label>
                    </div>
                </div>

            </div>
          </div>
        </div>
        <div class="actions">
          <div class="ui button cancel">Cancel</div>
          <div class="ui green button ok" style="min-width:200px">OK</div>
        </div>
        </div>
    """

    events:
        'click .ok': "confirm"
        'click .cancel': "abort"

    initialize: ({template}) =>
        @render()


    render: =>
        @$el.html(@template)
        @$modal = @$el.find('.ui.modal')
        @$modal.modal(
            detachable: false
            closable: false
        )
        @$modal.modal('show')
        @$modal.find('textarea.properties').val(@model.get('content'))
        @delegateEvents()
        $('.zombieguard').on("click", @zombieguard)

    confirm: =>
        @remove()

    abort: =>
        @remove()

    remove: =>
        @stopListening()
        @undelegateEvents()
        @off()
        @model.off null, null, @
        @$modal.modal('hide')
        @$modal.remove()
        
    zombieguard: =>
        alert(@classname)

module.exports =
    views: {DetailsView, MenuView}
    models: {CellModel, LinkModel, LinkCollection, CellCollection, ApplicationState, MetabookModel}