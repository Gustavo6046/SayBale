sbserv = require("../server.js").sbserv

post = (res, req) ->
    if req.ip in sbserv.ips
        sbserv.serveAjax(req.ip, "sendchat", req.body)
        res.send("{}")

module.exports = {
    post: post
    address: "sendchat"
    mimetype: "application/json"
}