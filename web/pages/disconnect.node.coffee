sbserv = require("../server.js").sbserv

post = (req, res) ->
    for a, _ of sbserv.ips
        if req.get("X-FORWARDED-FOR") == a
            sbserv.disconnect(req.get("X-FORWARDED-FOR"), sbserv.ips[req.get("X-FORWARDED-FOR")])
        
    {}

module.exports = {
    post: post
    address: "disconnect"
    mimetype: "application/json"
}