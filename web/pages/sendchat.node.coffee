sbserv = require("../server.js").sbserv

post = (req, res) ->
    console.log(JSON.stringify(req.body))

    for a, _ of sbserv.ips
        if req.remoteIP() == a
            sbserv.serveAjax(req.remoteIP(), "sendchat", req.body)
        
    {}

module.exports = {
    post: post
    address: "sendchat"
    mimetype: "application/json"
}