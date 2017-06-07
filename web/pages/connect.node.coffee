sbserv = require("../server.js").sbserv

post = (req, res) ->
    console.log("JSON request body: " + JSON.stringify(req.body))
    
    {status: sbserv.newUser(req.remoteIP(), req.body.nick.slice(0, 50))}

module.exports = {
    post: post
    address: "connect"
    mimetype: "application/json"
}