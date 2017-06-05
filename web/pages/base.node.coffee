fs = require("fs")
mime = require("mime")

get = (res, req) ->
    res.setHeader('Content-type', mime.lookup("pages/index.html"))

    fs.readFileSync("pages/index.html")

module.exports = {
    get: get
    address: ""
}