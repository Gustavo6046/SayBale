sbserv = {}
sbserv.ips = {}
sbserv.pendingData = {}
sbserv.users = []

sbserv.newUser = (ip, nick) ->
    if nick in sbserv.users
        false

    sbserv.users.push(nick)
    sbserv.pendingData[nick] = []
    sbserv.ips[ip] = nick

    true

sbserv.disconnect = (ip, nick) ->
    if sbserv.ips[ip] != nick
        false

    sbserv.users.remove(nick)
    sbserv.pendingData[nick] = undefined
    
    for k, v of sbserv.ips
        if v == nick
            sbserv.ips[k] = undefined

    true
    
sbserv.relay = (nick, text) ->
   sbserv.pendingData[nick].push({ nick: nick, text: text })

sbserv.serveAjax = (ip, addr, data) ->
    if addr == "sendchat"
        sbserv.relay(sbserv.ips[ip], data.text)
        return

    else if addr == "getchat"
        logs = sbserv.pendingData[sbsev.ips[ip]]
        sbserv.pendingData[sbsev.ips[ip]] = undefined
        {
            logs: logs
            next: 0.8
        }

module.exports = {
    sbserv: sbserv
}