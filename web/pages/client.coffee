nicked = false
nick = null
sendHistory = []
historyPos = -1
nonHistory = ""
cycle = 0
lastTab = ""
origTitle = document.title
selected = true

has = (a, i) ->
    for x in a
        if x == i
            return true

    return false

connect = (again) ->
    if not again?
        again = false

    if again
        nick = window.prompt("Already used! Use another nickname:", "default_user1").replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;").replace("'", "&apos;").slice(0, 50)

    else
        nick = window.prompt("Set your nickname:", "default_user").replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;").replace("'", "&apos;").slice(0, 50)

    $.ajax(
        "../connect", {
            type: "POST"
            data: JSON.stringify({ nick: nick })
            success: (data, status, req) ->
                if data.status == 1
                    connect(true)

                else if data.status == 2
                    alert("Your IP is banned.")
                    e = document.getElementById("inputs")
                    e.parent.removeChild(e)

            contentType: 'application/json'
        }
    )

sendText = ->
    if not nicked
        return false

    inputBox = document.getElementById("textArea")
    data = inputBox.value

    if data == ""
        return false

    historyPos = -1

    sendHistory.push(data)

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

changeNick = ->
    if not nicked
        return false

    nickBox = document.getElementById("commandParms")
    newNick = nickBox.value

    if newNick == ""
        return false
    
    nickBox.value = ""

    $.ajax(
        "../setnick", {
            type: "POST"
            data: JSON.stringify({ newNick: newNick })
            success: (data, status, req) ->
                console.log("[DEBUG] #{JSON.stringify(data)}")

                if data.continue
                    nick = newNick

                else
                    show("*** Can't change nick (server refused)")

            contentType: 'application/json'
        }
    )

    true

cmdNames = ["msg", "help", "nick", "adminauth", "kick", "kickban", "unban", "getips", "userlist"]
codes = ["color&lt;hex&gt;(stuff)", "bg&lt;hex&gt;(stuff)", "spoiler(stuff)", "img(url)", "timer&lt;seconds&gt;(stuff)", "ftmr&lt;seconds&gt;(stuff)"]

command = ->
    commandName = document.getElementById("commandName").value

    inputBox = document.getElementById("commandParms")
    data = inputBox.value

    if commandName == "msg"
        if data == ""
            return

        inputBox.value = ""

        $.ajax(
            "../sendchat", {
                type: "POST"
                data: JSON.stringify({ text: data, nick: nick })
                success: null
                contentType: 'application/json'
            }
        )

    else if commandName == "disconnect"
        if document.getElementById?
            document.getElementById("inputs").parentNode.removeChild(document.getElementById("inputs"))
            document.getElementById("logs").innerHTML += "</br>--- Disconnected."
        
        $.ajax(
            "../disconnect", {
                type: "POST"
                data: JSON.stringify({ reason: data })
                success: null
                contentType: "application/json"
            }
        )

    else if commandName == "nick"
        changeNick()
    
    else if commandName == "help"
        show("*** Commands available: #{cmdNames.join(' ')}")

    else if commandName == "codes"
        show("*** Codes available: #{codes.join(' ')}")
        
    else if commandName == "adminauth"
        pwBox = document.getElementById("commandParms")
        pass = pwBox.value
        pwBox.value = ""

        if pass == ""
            return
        
        $.ajax(
            "../adminauth", {
                type: "POST"
                data: JSON.stringify({ password: sha256.create().update(pass).hex() })
                success: (data, status, req) ->
                    if data.success
                        show("*** Logged as admin succesfully.")

                    else
                        show("*** Wrong password.")

                contentType: "application/json"
            }
        )

    else if commandName == "kick"
        paramBox = document.getElementById("commandParms")
        other = paramBox.value
        paramBox.value = ""

        $.ajax(
            "../kick", {
                type: "POST"
                data: JSON.stringify({ other: other })
                success: (data, status, req) ->
                    if data.success
                        show("*** Kicked #{other} succesfully.")

                    else
                        show("*** Kick operation refused (#{other} doesn't exist or you haven't authed as admin!).")

                contentType: "application/json"
            }
        )

    else if commandName == "kickban"
        paramBox = document.getElementById("commandParms")
        other = paramBox.value
        paramBox.value = ""

        $.ajax(
            "../kickban", {
                type: "POST"
                data: JSON.stringify({ banIP: other })
                success: (data, status, req) ->
                    if data.success
                        show("*** Banned IP #{other} succesfully.")

                    else
                        show("*** Kickban operation refused (IP #{other} doesn't exist or you haven't authed as admin!).")

                contentType: "application/json"
            }
        )

    else if commandName == "getips"
        paramBox = document.getElementById("commandParms")
        other = paramBox.value
        paramBox.value = ""

        $.ajax(
            "../getips", {
                type: "POST"
                data: JSON.stringify({ other: other })
                success: (data, status, req) ->
                    if data.success
                        show("*** #{other} IPs: #{data.ips.join(', ')}.")

                    else
                        show("*** IP retrieval operation refused (#{other} doesn't exist or you haven't authed as admin!).")

                contentType: "application/json"
            }
        )

    else if commandName == "unban"
        paramBox = document.getElementById("commandParms")
        other = paramBox.value
        paramBox.value = ""

        $.ajax(
            "../unban", {
                type: "POST"
                data: JSON.stringify({ banIP: other })
                success: (data, status, req) ->
                    if data.success
                        show("*** Unbanned IP #{other} succesfully.")

                    else
                        show("*** Unban operation refused (IP #{other} doesn't exist or you haven't authed as admin!).")

                contentType: "application/json"
            }
        )

    else if commandName == "userlist"
        $.ajax(
            "../userlist", {
                type: "POST"
                data: JSON.stringify()
                success: (data, status, req) ->
                    show("*** Users: #{data.users.join(' ')}")
                    show("*** Admins: #{data.admins.join(' ')}")

                contentType: "application/json"
            }
        )

    else
        show("*** Invalid command. Try 'help' on the bottom left text box for more commands!")

show = (text) ->
    parse([{ text: text, highlight: false, nick: "__noNick__" }])

validateSendText = (event) ->
    return sendText() if event.keyCode == 13 and not event.ctrlKey

    if event.keyCode == 13 and  event.ctrlKey
        $.ajax(
            "../userlist", {
                type: "POST"
                data: JSON.stringify()
                success: (data, status, req) ->
                    inputBox = document.getElementById("textArea")
                    word = inputBox.value.split(" ")[inputBox.value.split(" ").length - 1]

                    users = data.users
                    
                    if word == "" or has(word, users) and lastTab == ""
                        candidates = users

                        if candidates.length == 0
                            return

                        cycle++

                        if cycle >= candidates.length
                                cycle = 0

                    else
                        candidates = []

                        for x in users
                            if x.toLowerCase().startsWith(word.toLowerCase())
                                candidates.push(x)

                        if candidates.length == 0
                            return

                        if has(candidates, word)
                            word = lastTab

                        if lastTab == word and lastTab != ""
                            cycle++

                            if cycle >= candidates.length
                                cycle = 0

                        else
                            cycle = 0

                            if lastTab == ""
                                lastTab = word

                        if not has(candidates, word)
                            lastTab = word

                    if inputBox.value.split(" ").length > 1
                        inputBox.value = "#{inputBox.value.split(" ").slice(0, inputBox.value.split(" ").length - 1)} #{candidates[cycle]},"

                    else
                        inputBox.value = "#{candidates[cycle]}: "

                contentType: "application/json"
            }
        )

    else
        inputBox = document.getElementById("textArea")

        if historyPos == -1
            nonHistory = inputBox.value

        if event.keyCode == 38
            historyPos++

            if historyPos >= sendHistory.length
                historyPos = sendHistory.length - 1

        if event.keyCode == 40
            historyPos--
            
            if historyPos < -1
                historyPos = -1

        if historyPos > -1
            inputBox.value = sendHistory[sendHistory.length - historyPos - 1]

        else
            inputBox.value = nonHistory 

parseParen = (txt, stPos) ->
    if not (pos = stPos)?
        pos = 0

    res = txt.slice(pos, txt.length)

    numParens = 0
    inside = false
    subres = ""
    preres = ""

    while pos < txt.length
        ch = txt[pos]
        res += ch

        if ch == ")"
            if numParens == 1
                return { full: res, content: subres, prefix: preres }

            numParens--

        if inside and (ch != "(" or numParens > 0) and (ch != ")" or numParens > 0)
            subres += ch

        if ch == "("
            inside = true
            numParens++

        if not inside
            preres += ch

        pos++

    return {full: res, content: subres, prefix: preres}

parseMini = (txt) ->
    txt = txt.replace(new RegExp("[a-zA-Z1-9]+\\:\\/\\/[^ \\)]+", "ig"), (x) -> "<turl>#{x}</turl>" )
    txt = txt.replace(new RegExp("img\\(\\<turl\\>[a-zA-Z1-9]+\\:\\/\\/[^\\<]+\\<\\/turl\\>\\)", "ig"), (x) ->
        url = x.slice(10, x.length - 8)
        "<a href=\"#{url}\"><img src=\"#{url}\"></a>"
    )
    txt = txt.replace(new RegExp("\\<turl\\>([^\\<]+)\\<\\/turl\\>", "ig"), (x) ->
        "<a href=\"#{x.slice(6, x.length - 7)}\">#{x.slice(6, x.length - 7)}</a>"
    )
    txt = txt.replace(new RegExp("spoiler\\((.*)"), (x) ->
        x = parseParen(x)
        newSpoiler(parseMini(x.content))
    )
    txt = txt.replace(new RegExp("color([\\da-fA-F]{6})\\((.*)"), (x) ->
        x = parseParen(x)
        "<span style=\"color: #{'#' + x.prefix.slice(5)};\">#{parseMini(x.content)}</span>"
    )
    txt = txt.replace(new RegExp("bg([\\da-fA-F]{6})\\((.*)"), (x) ->
        x = parseParen(x)
        "<span style=\"background-color: ##{x.prefix.slice(2)};\">#{parseMini(x.content)}</span>"
    )
    txt = txt.replace(new RegExp("timer(\\d+)\\((.*)"), (a) ->
        a = parseParen(a)
        newTimer(parseMini(a.content), a.prefix.slice(5))
    )
    txt.replace(new RegExp("ftmr(\\d+)\\((.*)"), (a) ->
        a = parseParen(a)
        newfTimer(parseMini(a.content), a.prefix.slice(4))
    )

diffLog = (a, func) ->
    console.log("||| #{a} -> #{func(a)} |||")

parse = (logs) ->
    for d in logs
        if d.text? and d.text != ""
            if not selected
                document.title = "#{origTitle} [activity]"

            if new RegExp("^\\&lt;[^>]*\\&gt;", "i").test(d.text)
                pt = new RegExp("\\&lt;[^>]*\\&gt;", "i").exec(d.text)[0]
                _l = pt.length + 1

                d.text = d.text.slice(_l, d.text.length)
                d.text = d.text.replace(new RegExp("[a-zA-Z1-9]+\\:\\/\\/[^ \\)]+", "ig"), (x) -> "<turl>#{x}</turl>" )
                d.text = d.text.replace(new RegExp("img\\(\\<turl\\>[a-zA-Z1-9]+\\:\\/\\/[^\\<]+\\<\\/turl\\>\\)", "ig"), (x) ->
                    url = x.slice(10, x.length - 8)
                    "<a href=\"#{url}\"><img src=\"#{url}\"></a>"
                )
                d.text = d.text.replace(new RegExp("\\<turl\\>([^\\<]+)\\<\\/turl\\>", "ig"), (x) ->
                    "<a href=\"#{x.slice(6, x.length - 7)}\">#{x.slice(6, x.length - 7)}</a>"
                )
                d.text = d.text.replace(new RegExp("spoiler\\((.*)"), (x) ->
                    x = parseParen(x)
                    newSpoiler(parseMini(x.content))
                )
                d.text = d.text.replace(new RegExp("color([\\da-fA-F]{6})\\((.*)"), (x) ->
                    x = parseParen(x)
                    "<span style=\"color: #{x.prefix.slice(5)};\">#{parseMini(x.content)}</span>"
                )
                d.text = d.text.replace(new RegExp("bg([\\da-fA-F]{6})\\((.*)"), (x) ->
                    x = parseParen(x)
                    "<span style=\"background-color: ##{x.prefix.slice(2)};\">#{parseMini(x.content)}</span>"
                )
                d.text = d.text.replace(new RegExp("timer(\\d+)\\((.*)"), (a) ->
                    a = parseParen(a)
                    newTimer(parseMini(a.content), +a.prefix.slice(5))
                )
                d.text = d.text.replace(new RegExp("ftmr(\\d+)\\((.*)"), (a) ->
                    a = parseParen(a)
                    newfTimer(parseMini(a.content), a.prefix.slice(4))
                )

                d.text = "#{pt} #{d.text}"

            if d.text.indexOf(nick) != -1 and d.highlight and d.nick != nick
                new Audio("../highlight.wav").play()
                d.text = d.text.replace(new RegExp(nick, "g"), '<span class="highlight"><span id="nick" /></span>').replace('<span id="nick" />', nick)

            console.log(d.text)

            document.getElementById("logs").innerHTML += "</br>#{d.text}"

mainLoop = ->
    scroll = document.getElementById("logs").scrollTop == (document.getElementById("logs").scrollHeight - document.getElementById("logs").offsetHeight)

    $.ajax(
        "../getchat", {
            type: "POST"
            data: JSON.stringify({ nick: nick })
            success: (data, status, req) ->
                if data.continue? and data.continue
                    if data.logs?
                        parse(data.logs)
                        window.setTimeout(mainLoop, data.next * 1000)

                    else
                        window.setTimeout(mainLoop, 5000)
                
                else
                    disconnect()
                    show("You have disconnected.")

                window.setTimeout(->
                    if scroll
                        document.getElementById("logs").scrollTop = (document.getElementById("logs").scrollHeight - document.getElementById("logs").offsetHeight)

                data.next * 1000)

            contentType: 'application/json'
        }
    )

spoilerNums = 0
timerNums = 0

spoilerContent = {}
timerContent = {}

countTimer = (text, id, count) ->
    el = document.getElementById(id)

    if not el?
        return setTimeout((-> countTimer(text, id, count - 1)), 1000)

    count = +count

    if count <= 0
        el.innerHTML = "<span class=\"shownSpoiler\">#{text}</span>"

    else
        el.innerHTML = "<span id=\"#{id}\" class=\"hiddenSpoiler\" onload=\"setTimeout((function(){ countTimer(&quot;#{text}&quot;, &quot;#{id}&quot;, #{count}}, 1000 )\">#{count}</span>"
        
        setTimeout((-> countTimer(text, id, count - 1)), 1000)

newTimer = (text, count, id) ->
    if not id?
        id = "timer#{timerNums}"

    if count < 1
        count = 1

    timerNums++
    timerContent[id] = text

    setTimeout((-> countTimer(text, id, count - 1)), 1000)
    "<span id=\"#{id}\" class=\"hiddenSpoiler\" onload=\"setTimeout(function(){ countTimer(timerContent[&quot;#{id}&quot;], &quot;#{id}&quot;, #{count} }, 1000)\">#{count}</span>"

intervals = {}

countfTimer = (text, id, targ) ->
    el = document.getElementById(id)

    count = targ - (+new Date() / 1000)

    if count <= 0
        clearInterval(intervals[id])
        el.innerHTML = "<span class=\"shownSpoiler\">#{text}</span>"

    else
        el.innerHTML = "<span id=\"#{id}\" class=\"hiddenSpoiler\">#{count.toFixed(5)}</span>"

newfTimer = (text, count, id) ->
    if not id?
        id = "timer#{timerNums}"

    if (count = +count) < 1
        count = 1

    timerNums++
    timerContent[id] = text

    targ = (+new Date() / 1000) + count
    a = setInterval((-> countfTimer(text, id, targ)), 20)
    intervals[id] = a
    "<span id=\"#{id}\" class=\"hiddenSpoiler\" onload=\"setTimeout(function(){ countTimer(timerContent[&quot;#{id}&quot;], &quot;#{id}&quot;, #{count} }, 1000)\">#{count}.0</span>"

postSpoiler = (id) ->
    __wrapper__ = ->
        el = document.getElementById(id)

        el.addEventListener("change", (e) ->
            spoilerContent[id] = e.outerHTML
        )

    __wrapper__

newSpoiler = (text, id) ->
    if not id?
        id = "spoiler#{spoilerNums}"

    spoilerNums++
    spoilerContent[id] = text

    setTimeout(100, postSpoiler(id))
    "<span id=\"#{id}\" onclick=\"toggleSpoiler(&quot;#{id}&quot;, spoilerContent[&quot;#{id}&quot;])\"><span class=\"hiddenSpoiler\">+</div></span>"

toggleSpoiler = (id, text) ->
    el = document.getElementById(id)

    if el.childNodes[0].className == "hiddenSpoiler"
        el.childNodes[0].className = "shownSpoiler"
        el.childNodes[0].innerHTML = "> #{text}"

    else
        el.childNodes[0].className = "hiddenSpoiler"
        el.childNodes[0].innerHTML = "+"

disconnect = ->
    if document.getElementById?
        document.getElementById("inputs").parentNode.removeChild(document.getElementById("inputs"))
        document.getElementById("logs").innerHTML += "</br>--- Disconnected."

    $.ajax(
        "../disconnect", {
            type: "POST"
            data: JSON.stringify({ nick: nick })
            success: null
            contentType: 'application/json'
        }
    )

window.onload = ->
    window.onfocus = ->
        document.title = origTitle
        selected = true

    window.onblud = ->
        selected = false

    window.onbeforeunload = disconnect

    connect()

    nicked = true
    window.setTimeout(mainLoop, 1000)