// Generated by CoffeeScript 1.12.6
var post, sbserv;

sbserv = require("../server.js").sbserv;

post = function(req, res) {
  var _, a, ref;
  console.log(JSON.stringify(req.body));
  ref = sbserv.ips;
  for (a in ref) {
    _ = ref[a];
    if (req.get("X-FORWARDED-FOR") === a) {
      sbserv.serveAjax(req.get("X-FORWARDED-FOR"), "sendchat", req.body);
    }
  }
  return {};
};

module.exports = {
  post: post,
  address: "sendchat",
  mimetype: "application/json"
};
