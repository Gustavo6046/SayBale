sbserv = require("../server.js").sbserv

post = (res, req) ->
    if sbserv.newUser(req.ip, req.body.nick)
        res.send("{continue: true}")

    else
        res.send("{continue: false}")

module.exports = {
    post: post
    address: "connect"
    mimetype: "application/json"
}