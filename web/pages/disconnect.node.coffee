sbserv = require("../server.js").sbserv

post = (req, res) ->
    if req.ip in sbserv.ips
        sbserv.disconnect(req.ip, sbserv.ips[req.ip])
        {}

module.exports = {
    post: post
    address: "disconnect"
    mimetype: "application/json"
}