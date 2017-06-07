sbserv = require("../server.js").sbserv

post = (req, res) ->
    if sbserv.newUser(req.get("X-FORWARDED-FOR"), req.body.nick)
        console.log("JSON request body: " + JSON.stringify(req.body))

        {continue: true}

    else
        {continue: false}

module.exports = {
    post: post
    address: "connect"
    mimetype: "application/json"
}