metabook = {
    session: {}
    messages: {}
    ui: {}
    api: {}
    models: {}
    views: {}
    defaults: {}
}

metabook.api.get_template = (success, error) ->
    $.ajax(
        url: metabook.api.template_endpoint + metabook.api.path
        type: 'GET'
        success: success
        error: error
    )

metabook.api.get_file = (success, error) ->
    $.ajax(
        url: metabook.api.file_endpoint + metabook.api.path
        type: 'GET'
        success: success
        error: error
    )



class metabook.models.CellModel extends Backbone.Model
    initialize: (attributes, data) ->
        # TODO Something
        # @on('change', () -> alert('model changed'))
    update_data: (data) ->
        # alert(this)
        @set('source', data)

class metabook.models.CellCollection extends Backbone.Collection
    model: metabook.models.CellModel

class metabook.models.MetabookModel extends Backbone.Model
    initialize: (attributes, data) ->
        # data is the notebook object
        #
        # define if our metadata is present, i.e. this notebook has been set up to work as metabook

        # TODO: outdated; metadata is set in the initialization
        if not('metabook' of data.json.metadata)
            # inject template metadata
            data.json.metadata.metabook = data.template.metadata.metabook

        #build attributes
        @set('nbformat', data.json.nbformat)
        @set('nbformat_minor', data.json.nbformat_minor)
        #add metadata dict as instance variable
        @set('metadata', data.json.metadata)
        if data.json.metadata.metabook.id
            @set('id', data.json.metadata.metabook.id)
        @metadata = data.json.metadata



    actions:
        'notebook.save': (ev) ->
            # TODO execute PUT if id exists,
            # TODO execute POST if no id
            data = JSON.stringify(this)
            call_type = if this.id then 'PUT' else 'POST'
            $.ajax(
                url: metabook.api.file_endpoint + metabook.api.path
                type: call_type
                data: data
                success: _.bind(((json_data, status, xhr) ->
                    alert('Succesfully uploaded data.')
                    # TODO: 'new_id' is model id, update it
                    # TODO: 'new_name' is filename to fix in history
                    if json_data.new_id
                        @set('id', json_data.new_id)
                        history.replaceState(null, null, "./" + json_data.new_name)
                ), this)
                error: error_graph
            )



class metabook.views.MenuView extends Backbone.View

    events:
        "click [data-action]": (ev) ->
            _.bind(@model.actions[$(ev.target).data('action')], @model)(ev)