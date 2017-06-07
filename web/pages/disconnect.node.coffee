sbserv = require("../server.js").sbserv

post = (req, res) ->
    for a, _ of sbserv.ips
        if req.remoteIP() == a
            sbserv.disconnect(req.remoteIP(), sbserv.ips[req.remoteIP()])
        
    {}

module.exports = {
    post: post
    address: "disconnect"
    mimetype: "application/json"
}