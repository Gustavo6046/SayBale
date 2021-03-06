express = require('express')
bodyParser = require('body-parser')
fs = require('fs')
path = require('path')
mime = require('mime')

app = express()
modules = []
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))

startsWith = (s, sub) ->
    return s.slice(0, sub.length) == sub

endsWith = (s, sub) ->
    sub = sub.split("").reverse().join("")
    s = s.split("").reverse().join("")

    return startsWith(s, sub)

serve = (folder, fname, base) ->
    if not base?
        base = ""

    if fs.lstatSync(path.join(folder, fname)).isDirectory()
        return webFolder(path.join(folder, fname), undefined, path.join(base, fname))

    if endsWith(fname, ".node") or endsWith(fname, ".node.js")
        module = require("./" + path.join(base, folder, fname))

        console.log("Using '#{fname}' at address '/#{module.address}'")

        if module.get?
            app.get('/' + module.address, (req, res) ->
                req.remoteIP = ->
                    o = @get("X-FORWARDED-FOR")

                    if o?
                        o

                    else
                        @ip

                console.log("Attending GET request from #{req.ip} (through URL #{req.get("referer")} and remote IP #{req.remoteIP()}) for #{fname}")

                r = module.get(req, res)

                if not r? or not r.mimetype?
                    if module.mimetype?
                        res.setHeader('Content-Type', module.mimetype)

                    else
                        res.setHeader('Content-Type', 'text/html')

                else
                    res.setHeader('Content-Type', r.mimetype)
                
                if r? and r.data?
                    res.send(r.data)

                else if r?
                    res.send(r)

                else
                    res.send("")
            )

        if module.post?
            app.post('/' + module.address, (req, res) ->
                req.remoteIP = ->
                    o = @get("X-FORWARDED-FOR")

                    if o?
                        o

                    else
                        @ip

                console.log("Attending POST request from #{req.ip} (through URL #{req.get("referer")} and remote IP #{req.remoteIP()}) for #{fname}")

                r = module.post(req, res)

                if not r? or not r.mimetype?
                    if module.mimetype?
                        res.setHeader('Content-Type', module.mimetype)

                    else
                        res.setHeader('Content-Type', 'text/html')

                else
                    res.setHeader('Content-Type', r.mimetype)
                
                if r? and r.data?
                    res.send(r.data)

                else if r?
                    res.send(r)

                else
                    res.send("")
            )

        modules.push(module)

    
        console.log("Also using '#{fname}' at address '/#{path.join(base, fname).replace(/\\/g,"/")}'...'")

    else
        console.log("Using '#{fname}' at address '/#{path.join(base, fname).replace(/\\/g,"/")}'...'")

    app.get('/' + path.join(base, fname).replace(/\\/g,"/"), (req, res) ->
        req.remoteIP = ->
            o = @get("X-FORWARDED-FOR")

            if o?
                o

            else
                @ip

        console.log("Attending GET request from #{req.ip} (through URL #{req.get("referer")} and remote IP #{req.remoteIP()} for #{fname}")

        res.setHeader('Content-Type', mime.lookup(path.join(base, folder, fname)))
        res.send(fs.readFileSync(path.join(base, folder, fname)))
    )

webFolder = (f, next, base) ->
    console.log("Serving '#{f}'...")

    if not base?
        base = ""

    fs.readdir(f, (err, files) ->
        if err
            throw err

        for fn in files
            serve(f, fn, base)

        if next?
            next()
    )

done = (port) ->
    if not port?
        port = 3000

    app.listen(port, ->
        console.log("Listening on port #{port}.")

        for m in modules
            if m.init?
                m.init(port)
        )
        
module.exports = {
    done: done
    webFolder: webFolder
    app: app
    serve: serve
}