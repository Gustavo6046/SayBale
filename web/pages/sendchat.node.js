// Generated by CoffeeScript 1.12.6
var post, sbserv,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

sbserv = require("../server.js").sbserv;

post = function(res, req) {
  var ref;
  if (ref = req.ip, indexOf.call(sbserv.ips, ref) >= 0) {
    sbserv.serveAjax(req.ip, "sendchat", req.body);
    return res.send("{}");
  }
};

module.exports = {
  post: post,
  address: "sendchat",
  mimetype: "application/json"
};
