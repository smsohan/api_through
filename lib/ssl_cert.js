(function() {
  var SSLCert, child_process;

  child_process = require('child_process');

  SSLCert = (function() {
    function SSLCert(api_host) {
      this.api_host = api_host;
    }

    SSLCert.prototype.create = function(callback) {
      var certScript, scriptFile, spawn;
      console.log("cwd = ", process.cwd());
      spawn = require('child_process').spawn;
      scriptFile = require('path').join(__dirname, '..', 'scripts', 'host.sh');
      certScript = spawn(scriptFile, [this.api_host], process.cwd() + '/scripts');
      certScript.stdout.on('data', function(data) {
        return console.log('stdout: ' + data);
      });
      certScript.stderr.on('data', function(data) {
        return console.log('stderr: ' + data);
      });
      return certScript.on('exit', (function(_this) {
        return function(code) {
          console.log("Exited with code " + code);
          if (code !== 0) {
            throw new Error("Problem with cert generation for " + _this.api_host);
          }
          return callback();
        };
      })(this));
    };

    return SSLCert;

  })();

  module.exports = SSLCert;

}).call(this);
