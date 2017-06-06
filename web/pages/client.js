// Generated by CoffeeScript 1.12.6
var connect, mainLoop, nicked, parse, sendText;

nicked = false;

connect = function(again) {
  var nick;
  if (again == null) {
    again = false;
  }
  if (again) {
    nick = window.prompt("Already used! Use another nickname:", "default_user1");
  } else {
    nick = window.prompt("Set your nickname:", "default_user");
  }
  return $.post(window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "connect", {
    nick: nick
  }, function(data, status, req) {
    if (!data["continue"]) {
      return connect(true);
    }
  });
};

sendText = function() {
  var data, inputBox;
  if (!nicked) {
    false;
  }
  inputBox = document.getElementById("textArea");
  data = inputBox.value;
  if (data === "") {
    false;
  }
  $.post(window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "sendchat", {
    text: data
  }, null);
  inputBox.value = "";
  return true;
};

parse = function(logs) {
  var d, i, len, results;
  results = [];
  for (i = 0, len = logs.length; i < len; i++) {
    d = logs[i];
    results.push(document.getElementById("logs").innerHTML += "\n" + d.data);
  }
  return results;
};

mainLoop = function() {
  return $.post(window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + "getchat", {}, function(data, status, req) {
    if (data.logs != null) {
      parse(data.logs);
      return window.setTimeout(data.next, mainLoop);
    } else {
      return window.setTimeout(5, mainLoop);
    }
  });
};

connect();

nicked = true;

mainLoop();
