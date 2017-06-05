sbserv = require("../server.js").sbserv

post = (res, req) ->
    if req.ip in sbserv.ips
        if sbserv.newUser(req.ip, req.body.nick)
            "{continue: true}"

        else
            "{continue: false}"

module.exports = {
    post: post
    address: "connect"
}