// Generated by CoffeeScript 1.10.0
module.exports = {
  get_template: function(success, error) {
    return $.ajax({
      url: config.template_endpoint + config.file.path,
      type: 'GET',
      success: success,
      error: error
    });
  },
  get_file: function(success, error) {
    return $.ajax({
      url: config.file.endpoint + config.file.path,
      type: 'GET',
      success: success,
      error: error
    });
  },
  get_ajax_data: function(data_uri, success, error) {
    return $.ajax({
      url: data_uri,
      type: 'GET',
      success: success,
      error: error
    });
  },
  get_xhr: function(data_uri) {
    return $.ajax({
      url: data_uri,
      type: 'GET'
    });
  },
  is_good_form: function(json_data) {
    if (typeof json_data === 'object') {
      if ('metadata' in json_data) {
        if ('metabook' in json_data.metadata) {
          if ('links' in json_data.metadata.metabook) {
            return true;
          }
        }
      }
    }
    return false;
  },
  is_native: function(file_json) {
    if ('metadata' in file_json) {
      if (file_json.metadata.format === "native") {
        return true;
      }
    }
    return false;
  },
  get_cells: function(metabook_model) {
    return metabook_model.get('cells').models;
  },
  get_ids: function(cells) {
    var cell, i, ids, len;
    ids = [];
    for (i = 0, len = cells.length; i < len; i++) {
      cell = cells[i];
      ids.push(cell.id);
    }
    return ids;
  },
  get_links: function(metabook_model) {
    return metabook_model.get('links').models;
  }
};

//# sourceMappingURL=data.js.map
