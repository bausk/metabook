metabook.data = {}

metabook.data.get_template = (success, error) ->
    $.ajax(
        url: metabook.uri.template_endpoint + metabook.uri.file.path
        type: 'GET'
        success: success
        error: error
    )

metabook.data.get_file = (success, error) ->
    $.ajax(
        url: metabook.uri.file.endpoint + metabook.uri.file.path
        type: 'GET'
        success: success
        error: error
    )

metabook.data.get_ajax_data = (data_uri, success, error) ->
    $.ajax(
        url: data_uri
        type: 'GET'
        success: success
        error: error
    )

metabook.data.get_xhr = (data_uri) ->
    $.ajax(url: data_uri, type: 'GET')

metabook.data.is_good_form = (json_data) ->
    if typeof json_data is 'object'
        if 'metadata' of json_data
            if 'metabook' of json_data.metadata
                if 'links' of json_data.metadata.metabook
                    return true
    return false

metabook.data.is_native = (file_json) ->
    if 'metadata' of file_json
        if file_json.metadata.format == "native"
            return true
    return false

metabook.data.get_cells = (metabook_model) ->
    return metabook_model.get('cells')

metabook.data.get_links = (metabook_model) ->
    return metabook_model.get('links')