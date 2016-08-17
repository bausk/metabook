module.exports =

    get_template: (success, error) ->
        $.ajax(
            url: config.template_endpoint + config.file.path
            type: 'GET'
            success: success
            error: error
        )

    get_file: (success, error) ->
        $.ajax(
            url: config.file.endpoint + config.file.path
            type: 'GET'
            success: success
            error: error
        )

    get_ajax_data: (data_uri, success, error) ->
        $.ajax(
            url: data_uri
            type: 'GET'
            success: success
            error: error
        )

    get_xhr: (data_uri) ->
        $.ajax(url: data_uri, type: 'GET')

    is_good_form: (json_data) ->
        if typeof json_data is 'object'
            if 'metadata' of json_data
                if 'metabook' of json_data.metadata
                    if 'links' of json_data.metadata.metabook
                        return true
        return false

    is_native: (file_json) ->
        if 'metadata' of file_json
            if file_json.metadata.format == "native"
                return true
        return false

    get_cells: (metabook_model) ->
        return metabook_model.get('cells').models

    get_ids: (cells) ->
        ids = []
        for cell in cells
            ids.push(cell.id)
        return ids

    get_links: (metabook_model) ->
        return metabook_model.get('links').models