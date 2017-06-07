nicked = false
nick = null

connect = (again) ->
    if not again?
        again = false

    if again
        nick = window.prompt("Already used! Use another nickname:", "default_user1").replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;").replace("'", "&apos;")

    else
        nick = window.prompt("Set your nickname:", "default_user").replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;").replace("'", "&apos;")

    $.ajax(
        "../connect", {
            type: "POST"
            data: JSON.stringify({ nick: nick })
            success: (data, status, req) ->
                if not data.continue
                    connect(true)

            contentType: 'application/json'
        }
    )

sendText = ->
    if not nicked
        return false

    inputBox = document.getElementById("textArea")
    data = inputBox.valuex

    if data == ""
        return false

    inputBox.value = ""

    $.ajax(
        "../sendchat", {
            type: "POST"
            data: JSON.stringify({ text: data, nick: nick })
            success: null
            contentType: 'application/json'
        }
    )

    true

validateSendText = (event) ->
    sendText() if event.keyCode == 13

parse = (logs) ->
    for d in logs
        if d? and d != ""
            document.getElementById("logs").innerHTML += "</br>#{d}"

mainLoop = ->
    $.ajax(
        "../getchat", {
            type: "POST"
            data: JSON.stringify({ nick: nick })
            success: (data, status, req) ->
                if data.continue?
                    if data.logs?
                        parse(data.logs)
                        window.setTimeout(mainLoop, data.next * 1000)

                    else
                        window.setTimeout(mainLoop, 5000)
                
                else
                    disconnect()

            contentType: 'application/json'
        }
    )

disconnect = ->
    document.getElementById("inputs").parentNode.removeChild(document.getElementById("inputs"))

    $.ajax(
        "../disconnect", {
            type: "POST"
            data: JSON.stringify({ nick: nick })
            success: null
            contentType: 'application/json'
        }
    )

    document.getElementById("logs").innerHTML += "</br>--- Disconnected."

window.onload = ->
    connect()

    nicked = true
    window.setTimeout(mainLoop, 1000)