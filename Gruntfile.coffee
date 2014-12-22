module.exports = (grunt)->
  grunt.initConfig
    coffee:
      lib:
        files:
          'lib/application.js': 'src/lib/**/*.coffee'
          'index.js': 'src/index.coffee'

    watch:
      files: [
        'Gruntfile.coffee'
        'src/**/*.coffee'
      ]
      tasks: 'default'

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.registerTask('default', ['coffee'])