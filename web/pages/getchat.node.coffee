sbserv = require("../server.coffee").sbserv

data = (res, req) ->
    if req.ip in sbserv.ips
        JSON.stringify(sbserv.serveAjax(req.ip, "getchat", req.body))

module.exports = {
    data: data
    address: "getchat"
}