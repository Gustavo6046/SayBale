fs = require("fs")
mime = require("mime")

get = (req, res) ->
    res.set('Content-type', mime.lookup("pages/index.html"))

    fs.readFileSync("pages/index.html")

module.exports = {
    get: get
    address: ""
    mimetype: "html"
}