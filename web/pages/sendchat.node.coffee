sbserv = require("../server.coffee").sbserv

data = (res, req) ->
    if req.ip in sbserv.ips
        sbserv.serveAjax(req.ip, "sendchat", req.body)
        "{}"

module.exports = {
    data: data
    address: "sendchat"
}