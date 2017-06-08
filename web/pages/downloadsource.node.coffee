fs = require('fs')

post = (req, res) ->
    console.log(JSON.stringify(req.body))

    if ".." in req.body.path
        return { data: "HA HA HA! Nice try haxor.", mimetype: "text/plain" }

    for bl in JSON.parse(fs.readFileSync("blacklist.json")).blacklist
        if RegExp(bl, "ig").test(req.body.path)
            return { data: "HA HA HA! Nice try haxor.", mimetype: "text/plain" }

    try
        return { data: fs.readFileSync(req.body.path), mimetype: "application/octet-stream" }

    catch err
        reurn { data: "Error retrieving file: " + err, mimetype: "text/plain" }

module.exports = {
    post: post
    address: "downloadSource"
}