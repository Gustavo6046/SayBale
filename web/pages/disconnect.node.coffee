sbserv = require("../server.js").sbserv

post = (res, req) ->
    if req.ip in sbserv.ips
        sbserv.disconnect(req.ip, sbserv.ips[req.ip])
        res.send("{}")

module.exports = {
    post: post
    address: "disconnect"
    mimetype: "application/json"
}