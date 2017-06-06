sbserv = require("../server.js").sbserv

post = (req, res) ->
    if req.ip in sbserv.ips
        sbserv.serveAjax(req.ip, "getchat", req.body)

module.exports = {
    post: post
    address: "getchat"
    mimetype: "application/json"
}