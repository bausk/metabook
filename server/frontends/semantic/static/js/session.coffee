class metabook.session
    constructor: () ->




class metabook.messages.Message
    constructor: ({header, parent_header, metadata, content}) ->
        @header = header
    header: {}

class metabook.messages.ExecuteCellMessage extends metabook.messages.Message
    constructor: (content) ->
        header = {
            
        }
        super({content})

