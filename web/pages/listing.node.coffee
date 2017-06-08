fs = require('fs')
path = require('path')

walk = (foldername, fileFound, recurseCall, next, depth) ->
    if not depth?
        depth = 0

    for sub in fs.readdirSync(foldername)
        sub = path.join(foldername, sub)

        if fs.lstatSync(sub).isDirectory()
            if recurseCall?
                recurseCall(sub + "/", depth)

            walk(path.join(foldername, sub), fileFound, recurseCall, null, depth + 1)

        else if fileFound?
            fileFound(sub, depth)

    if next?
        next()

link = (url, title, post) ->
    if not title?
        title = url

    if post?
        "<form action=\"downloadSource\" method=\"POST\"><input type=\"hidden\" name=\"path\" value=\"#{url}\" /><a onclick=\"event.preventDefault(); this.parentNode.submit()\" href=\"#\">'#{title}'</a> (file)</form>"

    else
        "<span onclick=\"access(&quot;#{url.replace('\\', '\\\\')}&quot;)\" class=\"fakelink\">#{title}</span>"

get = (req, res) ->
    console.log(JSON.stringify(req.body))

    finalize = (html) ->
        res.send("<!DOCTYPE html>\n\n<html>\n      <head>\n        <title>SayBale source code</title>\n        <style> form { display: inline; magin: 0; padding: 0; } .fakelink { color: #ffffff; background-color: #139; } .fakelink:hover { color: #ffffff; background-color: #114; } .fakelink:activate { color: #ffffff; background-color: #9b2; } </style>\n        <script type=\"text/javascript\" src=\"domparser.min.js\"></script>\n        <script type=\"text/javascript\" src=\"jquery-3.1.1.min.js\"></script>\n        <style>.fakelink { color: #ffffff; background-color: #139; } .fakelink:active { color: #ffffff; background-color: #002; } .fakelink:hover { color: #ffffff; background-color: #114; }</style>\n        <script type=\"text/javascript\" src=\"listing.js\">></script>\n        <meta charset=\"utf-8\" />\n    </head>\n    <body>\n#{html}\n    </body>\n</html>")

    html = "Listing of current source code at \'.\'"

    walk(".", ((fname, depth) -> html += "<br/> #{'| '.repeat(depth)}" + link(fname, null, true)), ((fname, depth) -> html += "<br/> #{'| '.repeat(depth)} +" + link(fname) + " (directory)"), ->
        finalize(html)
    )

    return null

post = (req, res) ->
    console.log(JSON.stringify(req.body))
    
    if req.body.type == "dir"
        if req.body.pos.indexOf("..") != -1
            res.send("Permission denied to walk through parent dirs from anywhere for<br/>security reasons..")
            return

        html = "Listing of current source code at '#{req.body.pos}'"

        html += "<br\> <span onclick=\"access(&quot;#{path.join(req.body.pos, '..')}&quot;)\" class=\"fakelink\">..</span> (directory)"

        walk(req.body.pos, ((fname, depth) -> html += "<br/> #{'| '.repeat(depth)}" + link(fname, null, true)), ((fname, depth) -> html += "#{'| '.repeat(depth)} +" + link(fname) + " (directory)"), ->
            res.send(html)
        )

    else if req.body.type == "file"
        res.send("File downloads have moved. Try to use the interface correctly, jerk.")

    else
        return "Error: Bad type specified as request header."

module.exports = {
    get: get
    post: post
    address: "source"
    mimetype: "text/html"
}