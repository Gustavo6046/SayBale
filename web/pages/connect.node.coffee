sbserv = require("../server.js").sbserv

post = (req, res) ->
    if sbserv.newUser(req.ip, req.body.nick)
        {continue: true}

    else
        {continue: false}

module.exports = {
    post: post
    address: "connect"
    mimetype: "application/json"
}