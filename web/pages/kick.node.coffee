sbserv = require("../server.js").sbserv

post = (req, res) ->
    console.log(JSON.stringify(req.body))

    for a, _ of sbserv.ips
        if req.remoteIP() == a
            return sbserv.serveAjax(req.remoteIP(), "kick", req.body)
        
    {}

module.exports = {
    post: post
    address: "kick"
    mimetype: "application/json"
}