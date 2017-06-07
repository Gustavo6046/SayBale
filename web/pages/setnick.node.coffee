sbserv = require("../server.js").sbserv

post = (req, res) ->
    console.log(JSON.stringify(req.body))

    for a, _ of sbserv.ips
        if req.remoteIP() == a
            return sbserv.serveAjax(req.remoteIP(), "setnick", req.body)
        
    {continue: false}

module.exports = {
    post: post
    address: "setnick"
    mimetype: "application/json"
}