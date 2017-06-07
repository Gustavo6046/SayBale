sbserv = require("../server.js").sbserv

post = (req, res) ->
    for a, _ of sbserv.ips
        if req.get("X-FORWARDED-FOR") == a
            r = sbserv.serveAjax(req.get("X-FORWARDED-FOR"), "getchat", req.body)
            r.continue = true
            return r
            
    return { continue: false }

module.exports = {
    post: post
    address: "getchat"
    mimetype: "application/json"
}