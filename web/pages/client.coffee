nicked = false

connect = (again) ->
    if not again?
        again = false

    if again
        nick = Window.prompt("Already used! Use another nickname:", "default_user1")

    else
        nick = Window.prompt("Set your nickname:", "default_user")

    $.get(
        window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "/connect",
        { nick: nick },
        (data, status, req) ->
            if not data.continue
                connect(true)
        "json"
    )

sendText = ->
    if not nicked
        false

    inputBox = document.getElementByID("textArea")
    data = inputBox.value

    $.get(
        window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "/sendchat",
        { text: data },
        null,
        "json"
    )

    true

parse = (logs) ->
    for d in logs
        document.getElementByID("logs").innerHTML += "\n<#{logs.nickname}> #{logs.data}"

mainLoop = ->
    $.get(
        window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "/getchat",
        {},
        (data, status, req) ->
            parse(data.logs)
            Window.setTimeout(data.next, mainLoop)

        "json"
    )

window.onunload = ->
    $.get(
        window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "/disconnect",
        {},
        null,
        "json"
    )

connect()

nicked = true
mainLoop()