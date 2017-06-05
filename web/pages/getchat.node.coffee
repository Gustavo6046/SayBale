sbserv = require("../server.js").sbserv

post = (res, req) ->
    if req.ip in sbserv.ips
        JSON.stringify(sbserv.serveAjax(req.ip, "getchat", req.body))

module.exports = {
    post: post
    address: "getchat"
}