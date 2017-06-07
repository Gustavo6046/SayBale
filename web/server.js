// Generated by CoffeeScript 1.12.6
(function() {
  var htmlEntities, sbserv, ucLoop,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  sbserv = {};

  sbserv.ips = {};

  sbserv.pendingData = {};

  sbserv.lastGet = {};

  sbserv.users = [];

  sbserv.log = [];

  htmlEntities = function(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  };

  sbserv.newUser = function(ip, nick) {
    if (indexOf.call(sbserv.users, nick) >= 0) {
      false;
    }
    sbserv.relay("--> " + nick + " joined");
    console.log("[CHAT] --> " + nick + " joined");
    sbserv.users.push(nick);
    sbserv.pendingData[nick] = sbserv.log;
    sbserv.pendingData[nick].push("=== END OF LOGS ===");
    sbserv.pendingData[nick].push("--- Users: " + (sbserv.users.join(" ")));
    sbserv.lastGet[nick] = +new Date();
    sbserv.ips[ip] = nick;
    sbserv.relay();
    return true;
  };

  sbserv.disconnect = function(ip, nick) {
    var k, v;
    if (sbserv.ips[ip] !== nick) {
      return;
    }
    console.log("[CHAT] <-- " + nick + " left");
    sbserv.relay("<-- " + nick + " left");
    sbserv.users = sbserv.users.splice(sbserv.users.indexOf(nick), 1);
    delete sbserv.pendingData[nick];
    if ((function() {
      var ref, results;
      ref = sbserv.ips;
      results = [];
      for (k in ref) {
        v = ref[k];
        results.push(v === nick);
      }
      return results;
    })()) {
      return delete sbserv.ips[k];
    }
  };

  sbserv.relay = function(text) {
    var i, k, len, ref;
    if (text == null) {
      return;
    }
    text = htmlEntities(text);
    sbserv.log.push(text);
    ref = Object.keys(sbserv.pendingData);
    for (i = 0, len = ref.length; i < len; i++) {
      k = ref[i];
      if (sbserv.pendingData[k] != null) {
        sbserv.pendingData[k].push(text);
      }
    }
  };

  sbserv.serveAjax = function(ip, addr, data) {
    var logs;
    if (addr === "sendchat") {
      if (data.text === "") {
        return {};
      }
      console.log("[CHAT] <" + sbserv.ips[ip] + "> " + data.text);
      sbserv.relay("<" + sbserv.ips[ip] + "> " + data.text);
      return {};
    } else if (addr === "getchat") {
      sbserv.lastGet[sbserv.ips[ip]] = +new Date();
      logs = sbserv.pendingData[sbserv.ips[ip]];
      sbserv.pendingData[sbserv.ips[ip]] = [];
      return {
        logs: logs,
        next: 0.5,
        "continue": true
      };
    }
  };

  sbserv.findip = function(nick) {
    var k, ref, v;
    ref = sbserv.ips;
    for (k in ref) {
      v = ref[k];
      if (v === nick) {
        return k;
      }
    }
  };

  ucLoop = function() {
    var k, ref, results, v;
    ref = sbserv.lastGet;
    results = [];
    for (k in ref) {
      v = ref[k];
      if (+new Date() - v > 30000) {
        results.push(sbserv.disconnect(sbserv.findip(k), k));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  setInterval(ucLoop, 2000);

  module.exports = {
    sbserv: sbserv
  };

}).call(this);
