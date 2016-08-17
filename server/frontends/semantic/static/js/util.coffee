module.exports =
    get_parameter: (sParam) ->
        sPageURL = decodeURIComponent(window.location.search.substring(1))
        sURLVariables = sPageURL.split('&')

        for i in sURLVariables
            sParameterName = i.split('=')

            if sParameterName[0] is sParam
                return sParameterName[1] is undefined ? true : sParameterName[1]