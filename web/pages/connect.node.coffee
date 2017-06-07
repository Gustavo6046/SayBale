sbserv = require("../server.js").sbserv

post = (req, res) ->
    if sbserv.newUser(req.remoteIP(), req.body.nick.slice(0, 50))
        console.log("JSON request body: " + JSON.stringify(req.body))

        {continue: true}

    else
        {continue: false}

module.exports = {
    post: post
    address: "connect"
    mimetype: "application/json"
}