nicked = false

connect = (again) ->
    if not again?
        again = false

    if again
        nick = window.prompt("Already used! Use another nickname:", "default_user1")

    else
        nick = window.prompt("Set your nickname:", "default_user")

    $.post(
        window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "connect",
        { nick: nick },
        (data, status, req) ->
            if not data.continue
                connect(true)
    )

sendText = ->
    if not nicked
        false

    inputBox = document.getElementById("textArea")
    data = inputBox.value

    if data == ""
        false

    $.post(
        window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "sendchat",
        { text: data },
        null
    )

    inputBox.value = ""

    true

parse = (logs) ->
    for d in logs
        document.getElementById("logs").innerHTML += "\n#{d.data}"

mainLoop = ->
    $.post(
        window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "getchat",
        {},
        (data, status, req) ->  
            if data.logs?
                parse(data.logs)
                window.setTimeout(data.next, mainLoop)

            else
                window.setTimeout(5, mainLoop)
    )

connect()

nicked = true
mainLoop()