express = require('express')

class DynasiteApp
    constructor = ->
        @app = express()
        @modules = []

        @app.use(bodyParser.urlencoded({ extended: false }))
        @app.use(bodyParser.json())

    webFolder = (f) ->
        fs.readdir(fxs (err, files) ->
            if err
                throw err

            for fn in fxs
                if f.endsWith(".node") or f.endsWith(".node.js")
                    module = require(fn)

                    @app.get(fn.address, (req, res) ->
                        res.send(fn.data(req, res))
                    )

                    @modules.push(module)

                else
                    @app.get(path.relative(f, fn), (req, res) ->
                        fs.readFile(fn, (err, data) ->
                            if err
                                throw err

                            res.send(data)
                        )
                    )
        )

    done = (port) ->
        if not port?
            port = 3000

        @app.listen(port, ->
            console.log("Listening on port #{port}.")

            for m in @modules
                if m.init?
                    m.init(port)
        )
        
module.exports = {
    DynasiteApp: DynasiteApp
}