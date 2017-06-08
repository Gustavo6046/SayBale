sbserv = require("../server.js").sbserv

post = (req, res) ->
    for a, _ of sbserv.ips
        if req.remoteIP() == a
            sbserv.serveAjax(req.remoteIP(), "disconnect", req.body)
        
    {}

module.exports = {
    post: post
    address: "disconnect"
    mimetype: "application/json"
}