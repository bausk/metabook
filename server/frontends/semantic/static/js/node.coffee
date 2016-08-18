
Node = joint.shapes.basic.Generic.extend(_.extend({},
    joint.shapes.basic.PortsModelInterface,
        markup: '<g class="rotatable"><g class="scalable"><rect class="body"/></g><text class="label"/><g class="inPorts"/><g class="outPorts"/></g>',
        portMarkup: '<g class="port port<%= id %>"><circle class="port-body"/></g>',

        defaults: joint.util.deepSupplement({

            type: 'html.Node'
            size: { width: 350, height: 100 }
            inPorts: ['In[0]']
            outPorts: ['Out[0]']

            attrs:

                rect:
                    stroke: 'none'
                    fill: 'transparent'
                    'stroke-opacity': 0
                    'fill-opacity': 0
                '.':
                    magnet: false
                '.body':
                    width: 150, height: 150
                    stroke: '#000000'
                '.port-body':
                    r: 10
                    magnet: true
                    stroke: '#000000'
                text:
                    'pointer-events': 'none'
                '.label':
                    text: 'Model', 'ref-x': .5, 'ref-y': 10, ref: '.body', 'text-anchor': 'middle', fill: '#000000'
                '.inPorts .port-label':
                    x:-15, dy: 4, 'text-anchor': 'end', fill: '#000000'
                '.outPorts .port-label':
                    x: 15, dy: 4, fill: '#000000'
                '.inPorts circle': { fill: '#666666', 'stroke-opacity': 0  }
                '.outPorts circle': { fill: '#999999', 'stroke-opacity': 0 }
                '.inPorts .port-body': fill: '#333333'
                '.outPorts .port-body': fill: '#666666'

            head_content: 'Cell: ID'
            content: 'Click to edit code'
            footing_content: 'Version A4D3E453'
            node_markup:
                    head: '<span class="content_head">Code Cell: FGFDG3456FGDFE</span>'
                    node_viewer: '<div class="node_viewer"></div>'
                    node_editor: '<span class="ui form node_editor"><textarea class="node_coupled"></textarea></span>'
                    footing: '<span class="ui small label content_footing" style="font-family: monospace">Python file</span>'

        }, joint.shapes.basic.Generic.prototype.defaults),

        initialize: (attrs, data) ->

            @cell_model = data.cell_model
            @on('change', _.bind((() ->
                    console.log('<change:content>')
                    @cell_model.update_data(this)

                ), this)
            )

            @on('change:position', _.bind((() ->
                    #alert('small model change!')
                    @cell_model.update_data(this)
                ), this)
            )


            @updatePortsAttrs()
            @on('change:inPorts change:outPorts', @updatePortsAttrs, this)

            @constructor.__super__.constructor.__super__.initialize.apply(this, arguments)



        getPortAttrs: (portName, index, total, selector, type) ->
            attrs = {}
            portClass = 'port' + index
            portSelector = selector + '>.' + portClass
            portLabelSelector = portSelector + '>.port-label'
            portBodySelector = portSelector + '>.port-body'

            attrs[portLabelSelector] = {text: portName}
            attrs[portBodySelector] =
                port:
                    id: portName || _.uniqueId(type)
                    type: type
            attrs[portSelector] = {ref: '.body', 'ref-y': (39 / 38 + 0.5 + index) / (39 / 38 + total)}
            if selector is '.outPorts'
                attrs[portSelector]['ref-dx'] = 0
            return attrs

        custom_events:
            properties: () ->
                console.log("properties")
    )
)

module.exports = { Node }