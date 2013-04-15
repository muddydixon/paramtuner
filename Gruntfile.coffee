module.exports = (grunt)->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    dir:
      src: 'src'
      dist: '.'
    coffee:
      options:
        bare: true
      compile:
        files:
          './tuner.js': 'src/tuner.coffee'
          './lib/strategy.js': 'src/lib/strategy.coffee'
          './lib/strategy/greedy_strategy.js': 'src/lib/strategy/greedy_strategy.coffee'
          './lib/strategy/generalized_linear_strategy.js': 'src/lib/strategy/generalized_linear_strategy.coffee'
          './lib/tuning_watcher.js': 'src/lib/tuning_watcher.coffee'
    docco:
      tuner:
        src: [
          'src/index.coffee'
          'src/tuner.coffee'
          'src/lib/strategy.coffee'
          'src/lib/tuning_watcher.coffee'
          'src/lib/strategy/greedy_strategy.coffee'
          'src/lib/strategy/generalized_linear_strategy.coffee'
        ]
        options:
          output: 'docs/'
    simplemocha:
      all:
        src: 'test/**/*_test.coffee'
      options:
        globals: ['expect']
        timeout: 3000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
    watch:
      scripts:
        files: ['src/**/*.coffee', 'bin/*.js']
        tasks: ['simplemocha', 'coffee', 'docco']
        options:
          interrupt: true
          
    clean:
      files: [
        'tuner.js'
        'lib/'
        'docs/'
        ]
          
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-docco'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  grunt.registerTask 'default', ['simplemocha', 'coffee', 'docco']
  grunt.registerTask 'test', ['simplemocha']
