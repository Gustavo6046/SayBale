sbserv = require("../server.js").sbserv

post = (req, res) ->
    for a, _ of sbserv.ips
        if req.remoteIP() == a
            r = sbserv.serveAjax(req.remoteIP(), "getchat", req.body)
            r.continue = true
            return r
            
    return { continue: false }

module.exports = {
    post: post
    address: "getchat"
    mimetype: "application/json"
}