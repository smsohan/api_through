module.exports = (grunt)->
  grunt.initConfig
    coffee:
      lib:
        expand: true
        flatten: true
        src: ['src/lib/*.coffee']
        dest: 'lib/'
        ext: '.js'
      index:
        files:
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