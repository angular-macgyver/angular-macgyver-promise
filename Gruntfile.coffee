path = require "path"

module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-karma"

  grunt.initConfig
    package: grunt.file.readJSON "package.json"

    coffee:
      compile:
        files:
          "build/angular-mac-promise.js": [
            "src/module.coffee"
            "src/**/*.coffee"
          ]
    concat:
      js:
        dest: "build/js/vendor.js"
        src: [
          "vendor/bower/angular/angular.js"
        ]
      css:
        dest: "build/css/app.css"
        src: ["tmp/import.css"]
    stylus:
      compile:
        options:
          use: [require "nib"]
        files:
          "tmp/import.css": ["app/styles/import.styl"]
    jade:
      options:
        data:
          version: "<%= package.version %>"
      files:
        expand: true
        cwd: "app"
        src: ["**/*.jade"]
        ext: ".html"
        dest: "build"
    clean: ["tmp"]
    connect:
      server:
        options:
          port: 8080
          keepalive: true
    watch:
      js:
        files: ["src/**/*.coffee"]
        tasks: ["coffee"]
        options: interrupt: true
      css:
        files: ["app/**/*.styl", "app/**/**/*.styl"]
        tasks: ["stylus", "concat:css", "clean"]
        options: interrupt: true
      jade:
        files: ["app/**/*.jade"]
        tasks: ["jade"]
        options: interrupt: true
    karma:
      unit:
        configFile: "test/karma.conf.js"
        autoWatch: true

  # Helper Functions

  spawn = (options, done = ->) ->
    options.opts ?= stdio: "inherit"
    grunt.util.spawn options, done

  # Helper Routines

  runExample = ->
    @async()

    spawn
      grunt: true
      args: ["compile"]
    , ->
      spawn
        grunt: true
        args: ["watch"]

      spawn
        grunt: true
        args: ["server"]

  runDevelopment = ->
    @async()

    spawn
      grunt: true
      args: ["compile"]
    , ->
      spawn
        grunt: true
        args: ["karma"]

  # Custom Tasks
  
  grunt.registerTask "server", "Run the connect server", [
    "connect"
  ]

  grunt.registerTask "compile", "Compile all source code", [
    "coffee"
    "concat"
    "clean"
  ]

  grunt.registerTask "default", "Build, Watch, Karma", ->
    runDevelopment.call this

  grunt.registerTask "example", "Build, Watch, Server", ->
    runExample.call this
