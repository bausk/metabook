imports = {
    ui: require('./ui')
}

class MetaGraph extends joint.dia.Graph
    initialize: (attrs, data) ->
        @metabook = data
        @constructor.__super__.initialize.apply(this, arguments)


        # 1. obj is our input.
        # 2. metabook is our keys and settings
        # root: "{{root}}",
        # file_api_endpoint: "{{root}}/{{metabook_config.routes.api.file}}/",
        # file_id: "{% if 'new' in request.arguments %}{% else %}0123456789{% end %}",
        # path: "{{uri}}"
        # 3. branch for new vs saved notebook

    populate: () ->
        elems_list = []
        links_list = []

        cells = @metabook.get("cells")
        links = @metabook.get("links")

        # TODO: Differentiate between different nodes according to their core SHA1
        # TODO:
        # TODO:
        # TODO:

        cells.each( (cell_model) ->
            source = cell_model.get('source')
            id = cell_model.id
            if typeof(source) != "string"
                content = source.join("")
            else
                content = source
            position = cell_model.get('position')
            node = new joint.shapes.html.Node(
                id: id
                position: { x: position.x, y: position.y }
                content: content
                footing_content: "[ipynb cell]"
                node_markup:
                    node_viewer: '<div class="node_viewer python" data-metabook="true"></div>'
                    node_editor: '<span class="ui form node_editor"><textarea class="node_coupled"></textarea></span>'
                dimensions:
                    'min-height': 100
                    'max-height': 200
                    'min-width': 250
                    'max-width': 500
                inPorts: cell_model.get('inPorts')
                outPorts: cell_model.get('outPorts')
            , {cell_model}
            )
            elems_list.push(node)
        )

        links.each( (link_model) ->
            link = new joint.shapes.html.Link(
                source: link_model.get('source')
                target: link_model.get('target')
                id: link_model.get('id')
            )
            links_list.push(link)
        )

        @addCells([elems_list..., links_list...])


    custom_events:
        "node": imports.ui.Vent.passover
        "newnode": (ev) ->
            console.log("<graph:newnode>")

module.exports = MetaGraph