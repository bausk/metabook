
# closure example
makeCounter = ->
    count = 0
    {increment: -> count++
    getCount:  -> count}

counter = makeCounter()

$('#bTest1').on("click", ->
    counter.increment()
    alert(counter.getCount())
)
