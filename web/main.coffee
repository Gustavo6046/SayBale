dynasite = require("./request.coffee")

app = dynasite.DynasiteApp()
app.webFolder("pages/")
app.done()