// Generated by CoffeeScript 1.12.6
var access;

access = function(url) {
  console.log(url);
  if (url === ".") {
    return $.ajax("../source", {
      type: "GET",
      success: function(data, status, req) {
        return document.getElementsByTagName("BODY")[0].innerHTML = new DOMParser().parseFromString(data, "text/html").body.innerHTML;
      }
    });
  } else if (url.endsWith("/") || url.endsWith("\\")) {
    return $.ajax("../source", {
      type: "POST",
      data: {
        pos: url,
        type: "dir"
      },
      success: function(data, status, req) {
        return document.getElementsByTagName("BODY")[0].innerHTML = data;
      }
    });
  } else {
    return $.ajax("../source", {
      type: "POST",
      data: {
        pos: url,
        type: "file"
      },
      success: function(data, status, req) {
        return document.getElementsByTagName("BODY")[0].innerHTML += data;
      }
    });
  }
};