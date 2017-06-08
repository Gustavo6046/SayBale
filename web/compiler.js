// Generated by CoffeeScript 1.12.6
var child_process, coffee, compiled, fs, path;

fs = require('fs');

path = require('path');

child_process = require('child_process');

coffee = {};

compiled = function(fname, next) {
  var __wrapper__;
  return __wrapper__ = function(err, stdout, stderr) {
    if (next != null) {
      return next(fname, err, stdout, stderr);
    }
  };
};

coffee.compileFile = function(fname, next) {
  return child_process.exec("coffee -c -b " + fname, {
    timeout: 10
  }, compiled(fname, next));
};

coffee.countCoffees = function(foldername, fileFound, recurseCall, next) {
  var i, len, ref, sub;
  ref = fs.readdirSync(foldername);
  for (i = 0, len = ref.length; i < len; i++) {
    sub = ref[i];
    sub = path.join(foldername, sub);
    if (fs.lstatSync(sub).isDirectory()) {
      if (recurseCall != null) {
        recurseCall(sub);
      }
      coffee.countCoffees(path.join(foldername, sub), fileFound, recurseCall);
    } else if (sub.endsWith(".coffee") && (fileFound != null)) {
      fileFound(sub);
    }
  }
  if (next != null) {
    return next();
  }
};

coffee.compileFolderNoCount = function(foldername, num, curr, done, anyFound, dirFound, fileFound, compiled) {
  var curr2, i, len, ref, sub;
  curr2 = 0;
  ref = fs.readdirSync(foldername);
  for (i = 0, len = ref.length; i < len; i++) {
    sub = ref[i];
    sub = path.join(foldername, sub);
    if (anyFound != null) {
      anyFound(sub);
    }
    if (fs.lstatSync(sub).isDirectory()) {
      if (dirFound != null) {
        dirFound(sub);
      }
      coffee.compileFolderNoCount(sub, num, curr + curr2);
    } else if (sub.endsWith(".coffee")) {
      if (fileFound != null) {
        fileFound(sub, num, curr);
      }
      curr2 += 1;
      coffee.compileFile(sub, compiled);
    }
  }
  return curr2;
};

coffee.compileFolder = function(foldername, counted, anyFound, dirCount, dirFound, fileFound, compiled, compiling, next) {
  var curr, done, num;
  num = 0;
  curr = 0;
  done = 0;
  done = function(fname, error, stdout, stderr) {
    done++;
    if (compiled != null) {
      return compiled(fname, error, stdout, stderr);
    }
  };
  console.log("Counting...");
  coffee.countCoffees(foldername, (function(_) {
    return num++;
  }), dirCount, function() {
    var i, len, ref, results, sub;
    console.log("Starting compilation processes...");
    counted(num);
    ref = fs.readdirSync(foldername);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      sub = ref[i];
      sub = path.join(foldername, sub);
      if (anyFound != null) {
        anyFound(sub);
      }
      if (fs.lstatSync(sub).isDirectory()) {
        if (dirFound != null) {
          dirFound(sub);
        }
        results.push(curr += coffee.compileFolderNoCount(sub, num, done, curr, anyFound, dirFound, fileFound, done));
      } else if (sub.endsWith(".coffee")) {
        if (fileFound != null) {
          fileFound(sub, num, curr);
        }
        curr += 1;
        results.push(coffee.compileFile(sub, done));
      } else {
        results.push(void 0);
      }
    }
    return results;
  });
  if (compiling != null) {
    while (done < num) {
      compiling(num, done);
    }
  }
  if (next != null) {
    return next();
  }
};

module.exports = coffee;