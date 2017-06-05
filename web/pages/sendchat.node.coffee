sbserv = require("../server.js").sbserv

post = (res, req) ->
    if req.ip in sbserv.ips
        sbserv.serveAjax(req.ip, "sendchat", req.body)
        "{}"

module.exports = {
    post: post
    address: "sendchat"
}