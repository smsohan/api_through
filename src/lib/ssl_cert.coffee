child_process = require('child_process')

class SSLCert
  constructor: (@api_host)->

  create: (callback)->
    console.log("cwd = ", process.cwd())

    spawn = require('child_process').spawn
    scriptFile = require('path').join(__dirname, '..', 'scripts', 'host.sh');
    certScript = spawn(scriptFile, [@api_host], process.cwd() + '/scripts');

    certScript.stdout.on 'data', (data)->
      console.log('stdout: ' + data)

    certScript.stderr.on 'data', (data)->
      console.log('stderr: ' + data)

    certScript.on 'exit', (code)->
      console.log("Exited with code #{code}")
      if code != 0
        throw new Error("Problem with cert generation for #{@api_host}")

      callback()


module.exports = SSLCert