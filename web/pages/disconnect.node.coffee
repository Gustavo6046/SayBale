sbserv = require("../server.coffee").sbserv

data = (res, req) ->
    if req.ip in sbserv.ips
        sbserv.disconnect(req.ip, sbserv.ips[req.ip])
        "{}"

module.exports = {
    data: data
    address: "disconnect"
}