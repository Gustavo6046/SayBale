// Generated by CoffeeScript 1.12.6
(function() {
  var app, bodyParser, done, endsWith, express, fs, mime, modules, path, serve, startsWith, webFolder;

  express = require('express');

  bodyParser = require('body-parser');

  fs = require('fs');

  path = require('path');

  mime = require('mime');

  app = express();

  modules = [];

  app.use(bodyParser.json());

  startsWith = function(s, sub) {
    return s.slice(0, sub.length) === sub;
  };

  endsWith = function(s, sub) {
    sub = sub.split("").reverse().join("");
    s = s.split("").reverse().join("");
    return startsWith(s, sub);
  };

  serve = function(folder, fname, base) {
    var module;
    if (base == null) {
      base = "";
    }
    if (fs.lstatSync(path.join(folder, fname)).isDirectory()) {
      return webFolder(path.join(folder, fname), void 0, path.join(base, fname));
    }
    if (endsWith(fname, ".node") || endsWith(fname, ".node.js")) {
      module = require("./" + path.join(base, folder, fname));
      console.log("Using '" + fname + "' at address '/" + module.address + "'");
      if (module.get != null) {
        app.get('/' + module.address, function(req, res) {
          console.log("Attending GET request from " + req.ip + " for " + fname);
          res.setHeader('Content-type', module.mimetype);
          return res.send(module.get(req, res));
        });
      }
      if (module.post != null) {
        app.post('/' + module.address, function(req, res) {
          console.log("Attending POST request from " + req.ip + " for " + fname);
          res.setHeader('Content-type', module.mimetype);
          return res.send(module.post(req, res));
        });
      }
      return modules.push(module);
    } else {
      console.log("Using '" + fname + "' at address '/" + (path.join(base, fname).replace(/\\/g, "/")) + "'...'");
      return app.get('/' + path.join(base, fname).replace(/\\/g, "/"), function(req, res) {
        console.log("Attending GET request from " + req.ip + " for " + fname);
        res.setHeader('Content-type', mime.lookup(path.join(base, folder, fname)));
        return res.send(fs.readFileSync(path.join(base, folder, fname)));
      });
    }
  };

  webFolder = function(f, next, base) {
    console.log("Serving '" + f + "'...");
    if (base == null) {
      base = "";
    }
    return fs.readdir(f, function(err, files) {
      var fn, i, len;
      if (err) {
        throw err;
      }
      for (i = 0, len = files.length; i < len; i++) {
        fn = files[i];
        serve(f, fn, base);
      }
      if (next != null) {
        return next();
      }
    });
  };

  done = function(port) {
    if (port == null) {
      port = 3000;
    }
    return app.listen(port, function() {
      var i, len, m, results;
      console.log("Listening on port " + port + ".");
      results = [];
      for (i = 0, len = modules.length; i < len; i++) {
        m = modules[i];
        if (m.init != null) {
          results.push(m.init(port));
        } else {
          results.push(void 0);
        }
      }
      return results;
    });
  };

  module.exports = {
    done: done,
    webFolder: webFolder,
    app: app,
    serve: serve
  };

}).call(this);
