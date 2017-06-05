sbserv = require("../server.coffee").sbserv

data = (res, req) ->
    if req.ip in sbserv.ips
        if sbserv.newUser(req.ip, req.body.nick)
            "{continue: true}"

        else
            "{continue: false}"

module.exports = {
    data: data
    address: "connect"
}