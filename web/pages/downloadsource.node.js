// Generated by CoffeeScript 1.12.6
var fs, post,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

post = function(req, res) {
  var bl, err, i, len, ref;
  console.log(JSON.stringify(req.body));
  if (indexOf.call(req.body.path, "..") >= 0) {
    return {
      data: "HA HA HA! Nice try haxor.",
      mimetype: "text/plain"
    };
  }
  ref = JSON.parse(fs.readFileSync("blacklist.json")).blacklist;
  for (i = 0, len = ref.length; i < len; i++) {
    bl = ref[i];
    if (RegExp(bl, "ig").test(req.body.path)) {
      return {
        data: "HA HA HA! Nice try haxor.",
        mimetype: "text/plain"
      };
    }
  }
  try {
    return {
      data: fs.readFileSync(req.body.path),
      mimetype: "application/octet-stream"
    };
  } catch (error) {
    err = error;
    return reurn({
      data: "Error retrieving file: " + err,
      mimetype: "text/plain"
    });
  }
};

module.exports = {
  post: post,
  address: "downloadSource"
};
