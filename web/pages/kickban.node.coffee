sbserv = require("../server.js").sbserv

post = (req, res) ->
    console.log(JSON.stringify(req.body))

    for a, _ of sbserv.ips
        if req.remoteIP() == a
            return sbserv.serveAjax(req.remoteIP(), "kickban", req.body)
        
    {}

module.exports = {
    post: post
    address: "kickban"
    mimetype: "application/json"
}