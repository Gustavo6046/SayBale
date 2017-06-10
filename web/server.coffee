fs = require('fs')
sha256 = require('sha.js')('sha256')

has = (arr, item) ->
    for a in arr
        if a == item
            return true

    return false

remove = (arr, item) ->
    i = 0

    console.log(arr)

    if has(arr, item)
        a2 = arr
        a2.splice(arr.indexOf(item), 1)

        if has(a2, item)
            return remove(a2, item)

    return arr

sbserv = {}
sbserv.ips = {}
sbserv.pendingData = {}
sbserv.lastGet = {}
sbserv.users = []
sbserv.log = []
sbserv.admins = []
sbserv.bans = []
sbserv.adminKey = sha256.update(fs.readFileSync("adminpass.txt"), "utf8").digest("hex")

htmlEntities = (str) ->
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

sbserv.checkAdmin = (ip) ->
    for a in sbserv.admins
        if a == ip
            return true

    return false

sbserv.newUser = (ip, nick) ->
    for n in sbserv.users
        if nick == n
            return 1

    for b in sbserv.bans
        if b == ip
            return 2

    if ip in sbserv.ips
        disconnect(ip, sbserv.ips[ip], "Killed (old client #{sbserv.ips[ip]} overlapped with new client #{nick} for same IP)")

    sbserv.relay({ text: "--> #{nick} joined", nick: nick, highlight: false })
    console.log("[CHAT] --> #{nick} joined")

    sbserv.users.push(nick)
    sbserv.pendingData[nick] = sbserv.log
    sbserv.pendingData[nick].push({ text: "=== END OF LOGS ===", nick: nick, highlight: false })
    sbserv.pendingData[nick].push({ text: "--- Users: #{sbserv.users.join(" ")}", nick: nick, highlight: false })
    sbserv.pendingData[nick].push({ text: "--- Admins: #{[sbserv.ips[x] for x in sbserv.admins].join(" ")}", nick: nick, highlight: false })
    sbserv.lastGet[nick] = +new Date()
    sbserv.ips[ip] = nick

    sbserv.relay()

    0

sbserv.disconnect = (ip, nick, reason) ->
    if sbserv.ips[ip] != nick
        return

    reason = "" if not reason?
    reason = " (#{reason})" if reason?

    console.log("[CHAT] <-- #{nick} left#{reason}")
    sbserv.relay({ text: "<-- #{nick} left#{reason}", nick: nick, highlight: false })

    delete sbserv.pendingData[nick]
    delete sbserv.ips[k] if v == nick for k, v of sbserv.ips
    delete sbserv.lastGet[nick]

    sbserv.users = remove(sbserv.users, nick)

sbserv.relay = (text) ->
    if not text?
        return

    text.text = htmlEntities(text.text)

    sbserv.log.push(text)

    for k in Object.keys(sbserv.pendingData)
        sbserv.pendingData[k].push(text)

    return

sbserv.serveAjax = (ip, addr, data) ->
    if addr == "disconnect"
        if not data.reason?
            data.reason = null

    else if addr == "sendchat"
        if data.text == ""
            return {}

        console.log("[CHAT] <#{sbserv.ips[ip]}> #{data.text}")
        sbserv.relay({ text: "<#{sbserv.ips[ip]}> #{data.text}", nick: sbserv.ips[ip], highlight: true })
        return {}

    else if addr == "getchat"
        if (not has(sbserv.ips, ip)) or has(sbserv.bans, ip)
            {
                continue: false
                logs: []
                next: 5000
            }

        sbserv.lastGet[sbserv.ips[ip]] = +new Date()

        logs = sbserv.pendingData[sbserv.ips[ip]]
        sbserv.pendingData[sbserv.ips[ip]] = []
        {
            logs: logs
            next: 0.5   
            continue: true
        }

    else if addr == "setnick"
        for n in sbserv.users
            if data.newNick == n
                return { continue: false }

        nick = sbserv.ips[ip]
        
        sbserv.ips[ip] = data.newNick
        sbserv.pendingData[data.newNick] = sbserv.pendingData[nick]
        delete sbserv.lastGet[nick]
        delete sbserv.pendingData[nick]
        sbserv.users = remove(sbserv.users, nick)
        sbserv.users.push(data.newNick)

        sbserv.relay({ text: "*-* #{nick} changed his nickname to #{data.newNick}", nick: data.newNick, highlight: false })

        return { continue: true }

    else if addr == "adminauth"
        console.log("#{data.password} : #{sbserv.adminKey}")

        if data.password == sbserv.adminKey
            sbserv.admins.push(ip)
            sbserv.relay({ text: "+++ #{sbserv.ips[ip]} elevated to admin", nick: sbserv.ips[ip], highlight: false })
            {success: true}

        else
            {success: false}

    else if addr == "kick"
        if not sbserv.checkAdmin(ip)
            return {success: false}

        succ = false

        ks = []

        for k, v of sbserv.ips
            if v == data.other
                sbserv.relay({ text: "+++ #{sbserv.ips[ip]} kicked #{v}", nick: sbserv.ips[ip], highlight: false })
                ks.push([k, v])
                succ = true

        for a in ks
            sbserv.disconnect(a[0], a[1], "Kicked by #{sbserv.ips[ip]}")

        return {success: succ}

     else if addr == "kickban"
        if not sbserv.checkAdmin(ip)
            return {success: false}

        succ = false

        for k, v of sbserv.ips
            if k == data.banIP
                other = v

                sbserv.relay({ text: "+++ #{sbserv.ips[ip]} kickbanned #{v}", nick: sbserv.ips[ip], highlight: false })
                sbserv.disconnect(k, v, "Kickbanned by #{sbserv.ips[ip]}")

                succ = true

        sbserv.bans.push(data.banIP)

        return { success: succ }

    else if addr == "unban"
        if not sbserv.checkAdmin(ip)
            return {success: false}

        sbserv.bans = remove(sbserv.bans, data.banIP)
        sbserv.relay({ text: "+++ #{sbserv.ips[ip]} unbanned #{data.banIP}", nick: sbserv.ips[ip], highlight: false })

        return { success: true }

    else if addr == "getips"
        if not sbserv.checkAdmin(ip)
            return { success: false, ips: [] }

        ips = []

        for k, v of sbserv.ips
            if v == data.other
                ips.push(k)

        return { success: true, ips: ips }

    else if addr == "userlist"
        return { users: sbserv.users, admins: [sbserv.ips[x] for x in sbserv.admins] }

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