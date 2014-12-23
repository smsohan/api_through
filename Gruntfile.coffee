module.exports = (grunt)->
  grunt.initConfig
    coffee:
      src:
        lib:
          expand: true
          flatten: true
          src: ['src/lib/*.coffee']
          dest: 'lib/'
          ext: '.js'
        index:
          files:
            'index.js': 'src/index.coffee'
        # tests:
        #   expand: true
        #   flatten: true
        #   src: ['src/specs/*.coffee']
        #   dest: 'specs/'
        #   ext: '.js'

    watch:
      files: [
        'Gruntfile.coffee'
        'src/**/*.coffee'
      ]
      tasks: 'default'

    jasmine_node:
      options:
        specFolders:[]
        projectRoot:'.'
        forceExit: true
        match: '.'
        matchall: false
        extensions: 'js'
        specNameMatcher: 'spec'
        coffee: true
      all: ['src/specs/']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-jasmine-node')

  grunt.registerTask('default', ['coffee'])