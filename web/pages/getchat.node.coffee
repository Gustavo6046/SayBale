sbserv = require("../server.js").sbserv

post = (res, req) ->
    if req.ip in sbserv.ips
        res.send(JSON.stringify(sbserv.serveAjax(req.ip, "getchat", req.body)))

module.exports = {
    post: post
    address: "getchat"
    mimetype: "application/json"
}