sbserv = {}
sbserv.ips = {}
sbserv.pendingData = {}
sbserv.lastGet = {}
sbserv.users = []
sbserv.log = []

htmlEntities = (str) ->
    String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace /"/g, '&quot;'

sbserv.newUser = (ip, nick) ->
    if nick in sbserv.users
        false

    sbserv.relay("--> #{nick} joined")
    console.log("[CHAT] --> #{nick} joined")

    sbserv.users.push(nick)
    sbserv.pendingData[nick] = sbserv.log
    sbserv.pendingData[nick].push("=== END OF LOGS ===")
    sbserv.pendingData[nick].push("--- Users: #{sbserv.users.join(" ")}")
    sbserv.lastGet[nick] = +new Date()
    sbserv.ips[ip] = nick

    sbserv.relay()

    true

sbserv.disconnect = (ip, nick) ->
    if sbserv.ips[ip] != nick
        return

    console.log("[CHAT] <-- #{nick} left")
    sbserv.relay("<-- #{nick} left")

    sbserv.users = sbserv.users.splice(sbserv.users.indexOf(nick), 1)
    delete sbserv.pendingData[nick]
    delete sbserv.ips[k] if v == nick for k, v of sbserv.ips
    delete sbserv.lastGet(nick)

sbserv.relay = (text) ->
    if not text?
        return

    text = htmlEntities(text)

    sbserv.log.push(text)

    for k in Object.keys(sbserv.pendingData)
        if sbserv.pendingData[k]?
            sbserv.pendingData[k].push(text)

    return

sbserv.serveAjax = (ip, addr, data) ->
    if addr == "sendchat"
        if data.text == ""
            return {}

        console.log("[CHAT] <#{sbserv.ips[ip]}> #{data.text}")
        sbserv.relay("<#{sbserv.ips[ip]}> #{data.text}")
        return {}

    else if addr == "getchat"
        sbserv.lastGet[sbserv.ips[ip]] = +new Date()

        logs = sbserv.pendingData[sbserv.ips[ip]]
        sbserv.pendingData[sbserv.ips[ip]] = []
        {
            logs: logs
            next: 0.5   
            continue: true
        }

sbserv.findip = (nick) ->
    for k, v of sbserv.ips
        if v == nick
            return k

ucLoop = ->
    for k, v of sbserv.lastGet
        if +new Date() - v > 30000
            sbserv.disconnect(sbserv.findip(k), k) # getChat timeout

setInterval(ucLoop, 2000)

module.exports = {
    sbserv: sbserv
}